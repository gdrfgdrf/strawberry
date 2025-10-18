import 'dart:isolate';

import 'package:dartz/dartz.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:domain/entity/song_query_entity.dart';
import 'package:domain/repository/song_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/strawberry_usecase.dart';
import 'package:pair/pair.dart';

abstract class SongUseCase {
  void query(
    List<int> ids,
    void Function(Either<Failure, SongQueryEntity>) receiver, {
    bool cache = true,
  });

  void queryPlayerFiles(
    List<int> ids,
    SongQualityLevel level,
    void Function(Either<Failure, SongFileEntity>) receiver, {
    List<String> effects = const [],
    String? encodeType,
  });

  void downloadPlayerFiles(
    List<int> ids,
    SongQualityLevel level,
    void Function(Either<Failure, Pair<SongFileEntity, Stream<TransferableTypedData>>>) receiver, {
    List<String> effects = const [],
    String? encodeType,
  });
}

class SongUseCaseImpl extends StrawberryUseCase implements SongUseCase {
  final AbstractSongRepository songRepository;

  SongUseCaseImpl(this.songRepository);

  @override
  void query(
    List<int> ids,
    void Function(Either<Failure, SongQueryEntity>) receiver, {
    bool cache = true,
  }) {
    serviceLogger!.trace("querying songs, ids: $ids, cache: $cache");

    try {
      songRepository.query(ids, receiver);
    } catch (e, s) {
      serviceLogger!.error(
        "querying songs error, ids: $ids, cache: $cache: $e\n$s",
      );
    }
  }

  @override
  void queryPlayerFiles(
    List<int> ids,
    SongQualityLevel level,
    void Function(Either<Failure, SongFileEntity> p1) receiver, {
    List<String> effects = const [],
    String? encodeType,
  }) {
    serviceLogger!.trace(
      "querying player song files, ids: $ids, level: $level, effects: $effects, encode type: $encodeType",
    );

    try {
      songRepository.queryPlayerFiles(
        ids,
        level,
        receiver,
        effects: effects,
        encodeType: encodeType,
      );
    } catch (e, s) {
      serviceLogger!.error(
        "querying player song files error, ids: $ids, level: $level, effects: $effects, encode type: $encodeType: $e\n$s",
      );
    }
  }

  @override
  void downloadPlayerFiles(
    List<int> ids,
    SongQualityLevel level,
    void Function(Either<Failure, Pair<SongFileEntity, Stream<TransferableTypedData>>>) receiver, {
    List<String> effects = const [],
    String? encodeType,
  }) {
    serviceLogger!.trace(
      "downloading player song files, ids: $ids, level: $level, effects: $effects, encode type: $encodeType",
    );

    try {
      songRepository.downloadPlayerFiles(
        ids,
        level,
        receiver,
        effects: effects,
        encodeType: encodeType,
      );
    } catch (e, s) {
      serviceLogger!.error(
        "downloading player song files error, ids: $ids, level: $level, effects: $effects, encode type: $encodeType: $e\n$s",
      );
    }
  }
}
