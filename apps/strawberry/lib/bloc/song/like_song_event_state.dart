
import 'package:domain/result/result.dart';
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

class LikeSongFailure extends SongState {
  final int id;
  final bool like;
  final Failure failure;

  LikeSongFailure(this.id, this.like, this.failure);
}