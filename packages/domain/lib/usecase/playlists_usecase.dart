import 'package:dartz/dartz.dart';
import 'package:domain/entity/playlists_entity.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:domain/usecase/strawberry_usecase.dart';

import '../repository/playlist/playlists_repository.dart';
import '../result/result.dart';

abstract class PlaylistsUseCase {
  Future<Either<Failure, PlaylistsEntity>> userCreated(int userId);

  Future<Either<Failure, PlaylistsEntity>> userFavored(int userId);

  Future<Either<Failure, void>> cover(
    int id,
    String url,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
  });

  Future<Either<Failure, void>> coverBatch(
    List<ImageBatchItem> items,
    void Function(ImageBatchItemResult)? receiver, {
    bool cache = true,
  });
}

class PlaylistsUseCaseImpl extends StrawberryUseCase
    implements PlaylistsUseCase {
  final AbstractPlaylistsRepository playlistsRepository;

  PlaylistsUseCaseImpl(this.playlistsRepository);

  @override
  Future<Either<Failure, PlaylistsEntity>> userCreated(int userId) async {
    serviceLogger!.trace("getting user created playlists, userId: $userId");
    try {
      final result = await playlistsRepository.userCreated(userId);
      return Right(result);
    } catch (e, s) {
      serviceLogger!.error(
        "getting user created playlists error, userId: $userId: $e\n$s",
      );
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, PlaylistsEntity>> userFavored(int userId) async {
    serviceLogger!.trace("getting user favored playlists, userId: $userId");
    try {
      final result = await playlistsRepository.userFavored(userId);
      return Right(result);
    } catch (e, s) {
      serviceLogger!.error(
        "getting user favored playlists error, userId: $userId: $e\n$s",
      );
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, void>> cover(
    int id,
    String url,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
  }) async {
    serviceLogger!.trace(
      "getting playlist cover, id: $id, url: $url, cache: $cache",
    );
    try {
      playlistsRepository.cover(id, url, receiver, cache: cache);
      return Right(null);
    } catch (e, s) {
      serviceLogger!.error(
        "getting playlist cover error, id: $id, url: $url, cache: $cache: $e\n$s",
      );
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, void>> coverBatch(
    List<ImageBatchItem> items,
    void Function(ImageBatchItemResult)? receiver, {
    bool cache = true,
  }) async {
    serviceLogger!.trace("getting playlist cover batch");
    try {
      playlistsRepository.coverBatch(items, receiver, cache: cache);
      return Right(null);
    } catch (e, s) {
      serviceLogger!.error("getting playlist cover batch error: $e\n$s");
      return Left(Failure(e, s));
    }
  }
}
