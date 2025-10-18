import 'package:dartz/dartz.dart';
import 'package:domain/repository/album_repository.dart';
import 'package:domain/repository/image_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:get_it/get_it.dart';

import '../../cache/cache_system.dart';

class AlbumRepositoryImpl extends AbstractAlbumRepository {
  @override
  void cover(
    String id,
    String url,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
    int? width,
    int? height,
  }) {
    final imageRepository = GetIt.instance.get<AbstractImageRepository>();
    final imageItem = ImageItem(url, id, CacheChannel.albumCovers);

    imageRepository.fetch(
      imageItem,
      receiver,
      cache: cache,
      width: width,
      height: height,
    );
  }

  @override
  void coverPath(String id, String url, void Function(Either<Failure, String>) receiver, {int? width, int? height}) {
    final imageRepository = GetIt.instance.get<AbstractImageRepository>();
    final imageItem = ImageItem(url, id, CacheChannel.albumCovers);

    imageRepository.path(
      imageItem,
      receiver,
      width: width,
      height: height,
    );
  }
}
