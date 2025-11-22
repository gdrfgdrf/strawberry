import 'package:domain/result/result.dart';
import 'package:domain/usecase/song_usecase.dart';
import 'package:strawberry/bloc/song/download_player_song_files_event_state.dart';
import 'package:strawberry/bloc/song/get_song_lyrics_event_state.dart';
import 'package:strawberry/bloc/song/like_song_event_state.dart';
import 'package:strawberry/bloc/song/query_song_event_state.dart';
import 'package:strawberry/bloc/strawberry_bloc.dart';

abstract class SongEvent {}

abstract class SongState {}

class SongInitial extends SongState {}

class SongLoading extends SongState {}

class SongFailure extends SongState {
  final Failure failure;

  SongFailure(this.failure);
}

class SongBloc extends StrawberryBloc<SongEvent, SongState> {
  final SongUseCase songUseCase;

  SongBloc(this.songUseCase) : super(SongInitial()) {
    on<AttemptQuerySongEvent>((event, emit) async {
      emit(SongLoading());
      songUseCase.query(event.ids, event.receiver);
    });

    on<AttemptDownloadPlayerSongFilesEvent>((event, emit) async {
      emit(SongLoading());

      songUseCase.downloadPlayerFiles(
        event.ids,
        event.level,
        event.receiver,
        effects: event.effects,
        encodeType: event.encodeType,
      );
    });

    on<AttemptGetSongLyricsEvent>((event, emit) async {
      emit(SongLoading());

      final data = await songUseCase.getLyrics(event.id, cache: event.cache);
      data.fold(
        (failure) => emit(GetSongLyricsFailure(failure)),
        (lyrics) => emit(GetSongLyricsSuccess(lyrics)),
      );
    });

    on<AttemptLikeSongEvent>((event, emit) async {
      emit(SongLoading());

      final data = await songUseCase.like(event.id, event.like);
      data.fold(
        (failure) => emit(LikeSongFailure(event.id, event.like, failure)),
        (playlistId) => emit(LikeSongSuccess(event.id, event.like, playlistId)),
      );
    });
  }
}
