
import 'package:shared/lyric/lyric_parser.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';

class AttemptGetSongLyricsEvent extends SongEvent {
  final int id;

  AttemptGetSongLyricsEvent(this.id);
}

class GetSongLyricsSuccess extends SongState {
  final LyricsContainer lyricsContainer;

  GetSongLyricsSuccess(this.lyricsContainer);
}