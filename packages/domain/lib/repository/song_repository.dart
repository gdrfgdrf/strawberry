import 'dart:isolate';

import 'package:dartz/dartz.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:domain/entity/song_query_entity.dart';
import 'package:pair/pair.dart';

import '../result/result.dart';

abstract class AbstractSongRepository {
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
