
import 'package:strawberry/bloc/song/song_bloc.dart';

class AttemptFlushSongCacheEvent extends SongEvent {
  final int id;

  AttemptFlushSongCacheEvent(this.id);
}

class AttemptFlushLyricsCacheEvent extends SongEvent {
  final int id;

  AttemptFlushLyricsCacheEvent(this.id);
}

class FlushSongCacheSuccess extends SongState {
  final int id;

  FlushSongCacheSuccess(this.id);
}

class FlushLyricsCacheSuccess extends SongState {
  final int id;

  FlushLyricsCacheSuccess(this.id);
}