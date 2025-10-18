
import 'package:dartz/dartz.dart';
import 'package:domain/entity/playlist_query_entity.dart';
import 'package:domain/repository/playlist/playlist_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/strawberry_usecase.dart';

abstract class PlaylistUseCase {
  Future<Either<Failure, PlaylistQueryEntity>> query(int id, int songCount);
}

class PlaylistUseCaseImpl extends StrawberryUseCase implements PlaylistUseCase {
  final AbstractPlaylistRepository playlistRepository;
  
  PlaylistUseCaseImpl(this.playlistRepository);
  
  @override
  Future<Either<Failure, PlaylistQueryEntity>> query(int id, int songCount) async {
    serviceLogger!.trace("querying a playlist, id: $id, songCount: $songCount");
    try {
      final result = await playlistRepository.query(id, songCount);
      return Right(result);
    } catch (e, s) {
      serviceLogger!.error("querying a playlist error, id: $id, songCount: $songCount: $e\n$s");
      return Left(Failure(e, s));
    }
  }
}