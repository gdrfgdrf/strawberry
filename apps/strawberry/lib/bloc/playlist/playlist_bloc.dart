import 'package:dartz/dartz.dart';
import 'package:domain/entity/playlists_entity.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/playlist_usecase.dart';
import 'package:domain/usecase/playlists_usecase.dart';
import 'package:strawberry/bloc/playlist/get_playlist_cover_event_state.dart';
import 'package:strawberry/bloc/playlist/query_playlist_event_state.dart';
import 'package:strawberry/bloc/strawberry_bloc.dart';

import 'get_playlists_event_state.dart';

enum PlaylistSource { userCreated, userFavored }

abstract class PlaylistEvent {}

abstract class PlaylistState {}

class PlaylistInitial extends PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class PlaylistFailure extends PlaylistState {
  final Failure failure;

  PlaylistFailure(this.failure);
}

class PlaylistBloc extends StrawberryBloc<PlaylistEvent, PlaylistState> {
  final PlaylistsUseCase playlistsUseCase;
  final PlaylistUseCase playlistUseCase;

  PlaylistBloc(this.playlistsUseCase, this.playlistUseCase)
    : super(PlaylistInitial()) {
    on<AttemptGetPlaylistsEvent>((event, emit) async {
      emit(PlaylistLoading());

      final userId = event.userId;
      Either<Failure, PlaylistsEntity> result;
      switch (event.source) {
        case PlaylistSource.userCreated:
          {
            result = await playlistsUseCase.userCreated(userId);
          }
        case PlaylistSource.userFavored:
          {
            result = await playlistsUseCase.userFavored(userId);
          }
      }

      result.fold(
        (failure) => emit(GetPlaylistsFailure(failure)),
        (playlist) => emit(GetPlaylistsSuccess(playlist)),
      );
    });

    on<AttemptQueryPlaylistEvent>((event, emit) async {
      emit(PlaylistLoading());

      final result = await playlistUseCase.query(event.id, event.songCount);
      result.fold(
        (failure) => emit(PlaylistFailure(failure)),
        (query) => emit(QueryPlaylistSuccess(query)),
      );
    });

    on<AttemptQueryBasicPlaylistEvent>((event, emit) async {
      emit(PlaylistLoading());

      final result = await playlistUseCase.query(event.id, 0);
      result.fold(
            (failure) => emit(PlaylistFailure(failure)),
            (query) => emit(QueryBasicPlaylistSuccess(query)),
      );
    });

    on<AttemptGetPlaylistCoverEvent>((event, emit) async {
      emit(PlaylistLoading());

      final result = await playlistsUseCase.cover(
        event.id,
        event.url,
        event.receiver,
        cache: event.cache,
      );
      result.fold((failure) => emit(PlaylistFailure(failure)), (bytes) => {});
    });

    on<AttemptGetPlaylistCoverBatchEvent>((event, emit) {
      emit(PlaylistLoading());

      playlistsUseCase.coverBatch(
        event.items,
        event.receiver,
        cache: event.cache,
      );
    });
  }
}
