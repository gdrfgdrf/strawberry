
import 'package:dartz/dartz.dart';
import 'package:domain/entity/playlists_entity.dart';

import '../../result/result.dart';
import '../../usecase/image_usecase.dart';

abstract class AbstractPlaylistsRepository {
  Future<PlaylistsEntity> userCreated(int userId, {bool cache = true});
  Future<PlaylistsEntity> userFavored(int userId, {bool cache = true});
  void cover(
      int id,
      String url,
      void Function(Either<Failure, ImageItemResult>) receiver, {
        bool cache = true,
      });
  void coverBatch(
      List<ImageBatchItem> items,
      void Function(ImageBatchItemResult)? receiver, {
        bool cache = true,
      });
}