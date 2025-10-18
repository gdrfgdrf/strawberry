import 'package:dartz/dartz.dart';
import 'package:domain/repository/album_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:domain/usecase/strawberry_usecase.dart';

abstract class AlbumUseCase {
  void cover(
    String id,
    String url,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
    int? width,
    int? height,
  });

  void coverPath(
    String id,
    String url,
    void Function(Either<Failure, String>) receiver, {
    int? width,
    int? height,
  });
}

class AlbumUseCaseImpl extends StrawberryUseCase implements AlbumUseCase {
  final AbstractAlbumRepository albumRepository;

  AlbumUseCaseImpl(this.albumRepository);

  @override
  void cover(
    String id,
    String url,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
    int? width,
    int? height,
  }) {
    serviceLogger!.trace(
      "getting cover of a album, id: $id, url: $url, width: $width, height: $height",
    );
    try {
      albumRepository.cover(
        id,
        url,
        receiver,
        cache: cache,
        width: width,
        height: height,
      );
    } catch (e, s) {
      serviceLogger!.error(
        "getting cover of a album error, id: $id, url: $url, width: $width, height: $height: $e\n$s",
      );
    }
  }

  @override
  void coverPath(String id, String url, void Function(Either<Failure, String>) receiver, {int? width, int? height}) {
    serviceLogger!.trace(
      "getting cover path of a album, id: $id, url: $url, width: $width, height: $height",
    );
    try {
      albumRepository.coverPath(
        id,
        url,
        receiver,
        width: width,
        height: height,
      );
    } catch (e, s) {
      serviceLogger!.error(
        "getting cover path of a album error, id: $id, url: $url, width: $width, height: $height: $e\n$s",
      );
    }
  }
}
