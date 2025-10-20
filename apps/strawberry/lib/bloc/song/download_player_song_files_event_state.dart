import 'dart:isolate';

import 'package:dartz/dartz.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:domain/result/result.dart';
import 'package:pair/pair.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';

class AttemptDownloadPlayerSongFilesEvent extends SongEvent {
  final List<int> ids;
  final SongQualityLevel level;
  final void Function(
    Either<Failure, Pair<SongFileEntity, Stream<List<int>>>>,
  )
  receiver;
  final List<String> effects;
  final String? encodeType;

  AttemptDownloadPlayerSongFilesEvent(
    this.ids,
    this.level,
    this.receiver, {
    this.effects = const [],
    this.encodeType,
  });
}
