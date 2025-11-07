
import 'package:strawberry/bloc/song/song_bloc.dart';

class AttemptLikeSongEvent extends SongEvent {
  final int id;
  final bool like;

  AttemptLikeSongEvent(this.id, this.like);
}

class LikeSongSuccess extends SongState {
  final int id;
  final bool like;
  final int playlistId;

  LikeSongSuccess(this.id, this.like, this.playlistId);
}