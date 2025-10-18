import 'package:domain/result/result.dart';
import 'package:domain/usecase/album_usecase.dart';
import 'package:strawberry/bloc/album/get_album_cover_event_state.dart';
import 'package:strawberry/bloc/strawberry_bloc.dart';

abstract class AlbumEvent {}

abstract class AlbumState {}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumFailure extends AlbumState {
  final Failure failure;

  AlbumFailure(this.failure);
}

class AlbumBloc extends StrawberryBloc<AlbumEvent, AlbumState> {
  final AlbumUseCase albumUseCase;

  AlbumBloc(this.albumUseCase) : super(AlbumInitial()) {
    on<AttemptGetAlbumCoverEvent>((event, emit) async {
      emit(AlbumLoading());
      albumUseCase.cover(
        event.id,
        event.url,
        event.receiver,
        cache: event.cache,
        width: event.width,
        height: event.height,
      );
    });

    on<AttemptGetAlbumCoverPathEvent>((event, emit) async {
      emit(AlbumLoading());
      albumUseCase.coverPath(
        event.id,
        event.url,
        event.receiver,
        width: event.width,
        height: event.height,
      );
    });
  }
}
