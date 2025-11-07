import 'package:dartz/dartz.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:domain/entity/song_query_entity.dart';
import 'package:pair/pair.dart';
import 'package:shared/lyric/lyric_parser.dart';

import '../result/result.dart';

abstract class AbstractSongRepository {
  void query(
    List<int> ids,
    void Function(Either<Failure, SongQueryEntity>) receiver, {
    bool cache = true,
  });

  void downloadPlayerFiles(
    List<int> ids,
    SongQualityLevel level,
    void Function(Either<Failure, Pair<SongFileEntity, Stream<List<int>>>>)
    receiver, {
    List<String> effects = const [],
    String? encodeType,
    bool cache = true,
  });

  Future<LyricsContainer> getLyrics(int id, {bool cache = true});

  Future<int> like(int id, bool like);
}
