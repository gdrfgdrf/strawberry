import 'package:domain/result/result.dart';
import 'package:domain/usecase/user_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strawberry/bloc/user/get_user_avatar_event_state.dart';

import '../strawberry_bloc.dart';
import 'get_user_detail_event_state.dart';

abstract class UserEvent {}

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserFailure extends UserState {
  final Failure failure;

  UserFailure(this.failure);
}

class UserBloc extends StrawberryBloc<UserEvent, UserState> {
  final UserUseCase userUseCase;

  UserBloc(this.userUseCase) : super(UserInitial()) {
    on<AttemptGetUserDetailEvent_Type1>((event, emit) async {
      emit(UserLoading());

      final result = await userUseCase.userDetail_type1(
        event.userId,
        isLogin: event.isLogin,
      );

      result.fold(
        (failure) => emit(UserFailure(failure)),
        (profile) => emit(GetUserDetailSuccess_Type1(profile)),
      );
    });

    on<AttemptGetUserDetailEvent_Type2>((event, emit) async {
      emit(UserLoading());

      final result = await userUseCase.userDetail_type2(isLogin: event.isLogin);

      result.fold(
        (failure) => emit(UserFailure(failure)),
        (pair) => emit(GetUserDetailSuccess_Type2(pair)),
      );
    });

    on<AttemptGetUserAvatarEvent>((event, emit) async {
      emit(UserLoading());

      final result = await userUseCase.avatar(
        event.userId,
        event.url,
        event.cache,
        event.receiver,
      );
      result.fold((failure) => emit(UserFailure(failure)), (bytes) {});
    });

    on<AttemptGetUserAvatarBatchEvent>((event, emit) async {
      emit(UserLoading());

      final result = await userUseCase.avatarBatch(
        event.items,
        event.receiver,
        cache: event.cache,
      );
      result.fold(
        (failure) => emit(UserFailure(failure)),
        (bytes) => emit(GetUserAvatarBatchAllFutureCreatedEvent()),
      );
    });
  }
}
