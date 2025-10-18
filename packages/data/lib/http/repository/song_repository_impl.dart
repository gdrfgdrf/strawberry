import 'dart:convert';
import 'dart:isolate';

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

  void queryPlayerFilesFromNetwork(
    List<int> ids,
    SongQualityLevel level,
    void Function(Either<Failure, SongFileEntity>) receiver, {
    List<String> effects = const [],
    String? encodeType,
  }) {
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

          final inner = parsedResponse["data"];
          for (final songFileJson in inner ?? []) {
            final songFile = SongFileEntity.parseJson(
              jsonEncode(songFileJson ?? {}),
            );
            receiver(Right(songFile));
          }
        })
        .globalOnError((_, e, s) {
          receiver(Left(Failure(e, s)));
        })
        .run();
  }

  void downloadPlayerSongsFromNetwork(
    List<int> ids,
    SongQualityLevel level,
    void Function(
      Either<Failure, Pair<SongFileEntity, Stream<TransferableTypedData>>>,
    )
    receiver, {
    List<String> effects = const [],
    String? encodeType,
  }) {
    queryPlayerFilesFromNetwork(
      ids,
      level,
      (data) {
        data.fold((failure) {
          receiver(Left(failure));
        }, (songFile) {
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
            receiver(Right(Pair(songFile, stream)));
          });
        });
      },
      effects: effects,
      encodeType: encodeType,
    );
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
  void queryPlayerFiles(
    List<int> ids,
    SongQualityLevel level,
    void Function(Either<Failure, SongFileEntity> p1) receiver, {
    List<String> effects = const [],
    String? encodeType,
  }) {
    queryPlayerFilesFromNetwork(
      ids,
      level,
      receiver,
      effects: effects,
      encodeType: encodeType,
    );
  }

  @override
  void downloadPlayerFiles(
    List<int> ids,
    SongQualityLevel level,
    void Function(
      Either<Failure, Pair<SongFileEntity, Stream<TransferableTypedData>>>,
    )
    receiver, {
    List<String> effects = const [],
    String? encodeType,
  }) {
    downloadPlayerSongsFromNetwork(
      ids,
      level,
      receiver,
      effects: effects,
      encodeType: encodeType,
    );
  }
}
