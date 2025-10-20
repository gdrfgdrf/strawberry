import 'package:domain/result/result.dart';
import 'package:domain/usecase/song_usecase.dart';
import 'package:strawberry/bloc/song/download_player_song_files_event_state.dart';
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
  }
}
