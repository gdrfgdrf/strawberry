import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/isolate_pool_extensions.dart';
import 'package:data/isolatepool/task_chain.dart';
import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:domain/entity/song_query_entity.dart';
import 'package:domain/hives.dart';
import 'package:domain/repository/song_repository.dart';
import 'package:domain/result/result.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:pair/pair.dart';
import 'package:shared/lyric/lyric_parser.dart';

import '../../cache/cache_system.dart';
import '../../center/song_combination.dart';
import 'exception/api_service_exception.dart';

class SongRepositoryImpl extends AbstractSongRepository {
  void queryFromCenter(
    List<int> ids,
    void Function(Either<Failure, SongQueryEntity>) receiver,
  ) {
    if (ids.isEmpty) {
      return;
    }

    List<int> uncachedItems = [];

    for (int i = 0; i < ids.length; i++) {
      final id = ids[i];

      final box = Hive.box<SongCombination>(HiveBoxes.songCombination);
      final combination = box.get(id);
      final song = combination?.song;
      final privilege = combination?.privilege;

      if (song == null || privilege == null) {
        uncachedItems.add(id);
      } else {
        final query = SongQueryEntity({IndependentSome(song): privilege});
        receiver(Right(query));
      }
    }

    queryFromNetwork(uncachedItems, receiver);
  }

  List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  void queryFromNetwork(
    List<int> ids,
    void Function(Either<Failure, SongQueryEntity>) receiver,
  ) {
    if (ids.isEmpty) {
      return;
    }

    /// 网易云接口限制了每次请求只能 <= 1000 首歌
    for (final idsChunk in chunkList(ids, 1000)) {
      final endpoint = GetIt.instance.get<UrlProvider>().songDetails(idsChunk);
      final taskStream = TaskChain();

      taskStream
          .stringNetwork(() => endpoint)
          .onComplete((response, _) {
            final parsedResponse = jsonDecode(response);
            if (parsedResponse["code"] != 200) {
              final exception = ApiServiceException(
                parsedResponse["message"] ?? parsedResponse.toString(),
              );
              receiver(Left(Failure(exception, StackTrace.current)));
              return;
            }
            final query = SongQueryEntity.parseJson(response);

            query.map.forEach((songOption, privilege) {
              if (songOption is! IndependentSome) {
                return;
              }
              final value = (songOption as IndependentSome).value as SongEntity;

              final box = Hive.box<SongCombination>(HiveBoxes.songCombination);
              box.put(value.id, SongCombination(value, privilege));

              final split = SongQueryEntity({songOption: privilege});
              receiver(Right(split));
            });
          })
          .globalOnError((_, e, s) {
            receiver(Left(Failure(e, s)));
          })
          .run();
    }
  }

  void queryPlayerFiles(
    List<int> ids,
    SongQualityLevel level,
    void Function(Either<Failure, SongFileEntity>) receiver, {
    List<String> effects = const [],
    String? encodeType,
    bool cache = true,
  }) {
    final actualIds = <int>[];

    if (cache) {
      final box = Hive.box<SongFileEntity>(HiveBoxes.songFile);

      for (final id in ids) {
        final songFile = box.get(id);
        if (songFile == null) {
          actualIds.add(id);
          continue;
        }
        receiver(Right(songFile));
      }
    } else {
      actualIds.addAll(ids);
    }

    final endpoint = GetIt.instance.get<UrlProvider>().songPlayerFiles(
      ids,
      level,
      effects: effects,
      encodeType: encodeType,
    );
    final taskStream = TaskChain();

    taskStream
        .stringNetwork(() => endpoint)
        .onComplete((response, _) {
          final parsedResponse = jsonDecode(response);

          if (parsedResponse["code"] != 200) {
            final exception = ApiServiceException(
              parsedResponse["message"] ?? parsedResponse.toString(),
            );
            receiver(Left(Failure(exception, StackTrace.current)));
            return;
          }

          final box = Hive.box<SongFileEntity>(HiveBoxes.songFile);
          final inner = parsedResponse["data"];
          for (final songFileJson in inner ?? []) {
            final songFile = SongFileEntity.parseJson(
              jsonEncode(songFileJson ?? {}),
            );
            box.put(songFile.id, songFile);
            receiver(Right(songFile));
          }
        })
        .globalOnError((_, e, s) {
          receiver(Left(Failure(e, s)));
        })
        .run();
  }

  @override
  void query(
    List<int> ids,
    void Function(Either<Failure, SongQueryEntity>) receiver, {
    bool cache = true,
  }) {
    if (cache) {
      queryFromCenter(ids, receiver);
      return;
    }
    queryFromNetwork(ids, receiver);
  }

  @override
  void downloadPlayerFiles(
    List<int> ids,
    SongQualityLevel level,
    void Function(Either<Failure, Pair<SongFileEntity, Stream<List<int>>>>)
    receiver, {
    List<String> effects = const [],
    String? encodeType,
    bool cache = true,
  }) {
    queryPlayerFiles(
      ids,
      level,
      cache: cache,
      (data) {
        data.fold(
          (failure) {
            receiver(Left(failure));
          },
          (songFile) async {
            final id = songFile.id.toString();

            if (cache) {
              final cacheSystem = await GetIt.instance.getAsync<CacheSystem>();
              final cacheManager = cacheSystem.manager(CacheChannel.songs);

              final shouldUpdate = await cacheManager.shouldUpdate(
                id,
                songFile.md5,
              );
              if (!shouldUpdate) {
                final bytes = await cacheManager.fetch(id);
                receiver(Right(Pair(songFile, Stream.value(bytes))));
                return;
              }
            }

            if (songFile.url == null) {
              receiver(
                Left(Failure(Exception("url is null"), StackTrace.current)),
              );
              return;
            }

            final parsedUrl = Uri.parse(songFile.url!);

            final endpoint = Endpoint(
              path: songFile.url!.substring(parsedUrl.origin.length),
              method: HttpMethod.get,
              baseUrl: parsedUrl.origin.replaceAll("http", "https"),
            );

            sendStreamNetwork(endpoint, (stream) {
              final bytes = <int>[];

              final streamController = StreamController<List<int>>();
              StreamSubscription? subscription;
              subscription = stream.listen(
                (data) {
                  final received = data.materialize().asUint8List();
                  bytes.addAll(received);
                  streamController.add(received);
                },
                onDone: () async {
                  subscription?.cancel();
                  streamController.close();
                  if (bytes.isEmpty) {
                    return;
                  }
                  final cacheSystem =
                      await GetIt.instance.getAsync<CacheSystem>();
                  final cacheManager = cacheSystem.manager(CacheChannel.songs);
                  cacheManager.cache(id, songFile.md5, bytes);
                },
                onError: (e, s) {
                  streamController.addError(e, s);
                },
              );

              receiver(Right(Pair(songFile, streamController.stream)));
            });
          },
        );
      },
      effects: effects,
      encodeType: encodeType,
    );
  }

  @override
  Future<LyricsContainer> getLyrics(int id) {
    final completer = Completer<LyricsContainer>();
    final endpoint = GetIt.instance.get<UrlProvider>().songLyric(id);
    final taskChain = TaskChain();

    taskChain
        .stringNetwork(() => endpoint)
        .onComplete((response, _) {
          final parsedResponse = jsonDecode(response);

          if (parsedResponse["code"] != 200) {
            final exception = ApiServiceException(
              parsedResponse["message"] ?? parsedResponse.toString(),
            );
            completer.completeError(exception);
            return;
          }

          completer.complete(LyricParser.parse(response));
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }
}
