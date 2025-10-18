
import 'package:dartz/dartz.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:domain/result/result.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';

class AttemptQueryPlayerSongFilesEvent extends SongEvent {
  final List<int> ids;
  final SongQualityLevel level;
  final void Function(Either<Failure, SongFileEntity>) receiver;
  final List<String> effects;
  final String? encodeType;

  AttemptQueryPlayerSongFilesEvent(
      this.ids,
      this.level,
      this.receiver, {
        this.effects = const [],
        this.encodeType,
      });
}