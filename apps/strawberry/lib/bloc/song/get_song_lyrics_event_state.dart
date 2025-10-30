import 'package:domain/result/result.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';

class AttemptGetSongLyricsEvent extends SongEvent {
  final int id;
  final bool cache;

  AttemptGetSongLyricsEvent(this.id, {this.cache = true});
}

class GetSongLyricsSuccess extends SongState {
  final LyricsContainer lyricsContainer;

  GetSongLyricsSuccess(this.lyricsContainer);
}

class GetSongLyricsFailure extends SongState {
  final Failure failure;

  GetSongLyricsFailure(this.failure);
}
