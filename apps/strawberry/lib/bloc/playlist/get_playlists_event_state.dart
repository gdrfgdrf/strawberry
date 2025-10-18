
import 'package:domain/entity/playlists_entity.dart';
import 'package:domain/result/result.dart';
import 'package:strawberry/bloc/playlist/playlist_bloc.dart';

class AttemptGetPlaylistsEvent extends PlaylistEvent {
  final int userId;
  final PlaylistSource source;

  AttemptGetPlaylistsEvent(this.userId, this.source);
}

class GetPlaylistsSuccess extends PlaylistState {
  final PlaylistsEntity playlists;

  GetPlaylistsSuccess(this.playlists);
}

class GetPlaylistsFailure extends PlaylistFailure {
  GetPlaylistsFailure(super.failure);
}