import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/task_chain.dart';
import 'package:domain/entity/playlists_entity.dart';
import 'package:domain/repository/image_repository.dart';
import 'package:domain/repository/playlist/playlists_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:get_it/get_it.dart';

import '../../../cache/cache_system.dart';
import '../exception/api_service_exception.dart';

class PlaylistsRepositoryImpl extends AbstractPlaylistsRepository {
  Future<PlaylistsEntity> fromNetwork(int userId) {
    final completer = Completer<PlaylistsEntity>();
    final endpoint = GetIt.instance.get<UrlProvider>().playlists(userId);
    final taskStream = TaskChain();

    taskStream
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

          final playlists = PlaylistsEntity.parseJson(response);
          completer.complete(playlists);
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }

  @override
  Future<PlaylistsEntity> userCreated(
      int userId, {
    bool cache = true,
  }) async {
    final entity = await fromNetwork(userId);
    final list = entity.playlists.toList();
    list.removeWhere((playlist) {
      if (playlist.creator.userId != userId) {
        return true;
      }
      return false;
    });

    return PlaylistsEntity(entity.more, list);
  }

  @override
  Future<PlaylistsEntity> userFavored(
      int userId, {
    bool cache = true,
  }) async {
    final entity = await fromNetwork(userId);
    final list = entity.playlists.toList();
    list.removeWhere((playlist) {
      if (playlist.creator.userId == userId) {
        return true;
      }
      return false;
    });

    return PlaylistsEntity(entity.more, list);
  }

  @override
  void cover(
    int id,
    String url,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
  }) {
    final imageRepository = GetIt.instance.get<AbstractImageRepository>();
    final imageItem = ImageItem(url, id.toString(), CacheChannel.playlistCovers);
    imageRepository.fetch(
      imageItem,
      receiver,
      cache: cache,
    );
  }

  @override
  void coverBatch(
    List<ImageBatchItem> items,
    void Function(ImageBatchItemResult)? receiver, {
    bool cache = true,
  }) {
    for (final item in items) {
      final id = item.cacheTag;
      final url = item.url;

      cover(int.parse(id), url, (data) {
        data.fold(
          (failure) {
            final result = ImageBatchItemResult(url, id, null);
            receiver?.call(result);
          },
          (result) {
            final batchResult = ImageBatchItemResult(url, id, result.bytes);
            receiver?.call(batchResult);
          },
        );
      }, cache: cache);
    }
  }
}
