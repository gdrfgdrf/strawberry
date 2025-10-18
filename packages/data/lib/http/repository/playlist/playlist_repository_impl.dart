import 'dart:async';
import 'dart:convert';

import 'package:data/http/repository/exception/api_service_exception.dart';
import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/task_chain.dart';
import 'package:domain/entity/playlist_query_entity.dart';
import 'package:domain/repository/playlist/playlist_repository.dart';
import 'package:get_it/get_it.dart';

class PlaylistRepositoryImpl extends AbstractPlaylistRepository {
  @override
  Future<PlaylistQueryEntity> query(int id, int songCount) {
    final completer = Completer<PlaylistQueryEntity>();
    final endpoint = GetIt.instance.get<UrlProvider>().playlistQuery(
      id,
      songCount,
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
            completer.completeError(exception);
            return;
          }
          completer.complete(PlaylistQueryEntity.parseJson(response));
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }
}
