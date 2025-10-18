import 'package:domain/result/result.dart';
import 'package:domain/usecase/auth_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:strawberry/bloc/auth/refresh_token_event_state.dart';
import 'package:strawberry/bloc/auth/register_anonimous_event_state.dart';
import 'package:strawberry/bloc/strawberry_bloc.dart';

import 'login_event_state.dart';

abstract class AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthFailure extends AuthState {
  final Failure failure;

  AuthFailure(this.failure);
}

class AuthBloc extends StrawberryBloc<AuthEvent, AuthState> {
  final AuthUseCase authUseCase;

  AuthBloc(this.authUseCase) : super(AuthInitial()) {
    on<AttemptRegisterAnonimousEvent>((event, emit) async {
      emit(AuthLoading());

      final result = await authUseCase.registerAnonimous(event.deviceId);

      result.fold(
        (failure) => emit(AuthFailure(failure)),
        (entity) => emit(RegisterAnonimousSuccess(entity)),
      );
    });

    on<AttemptLoginCellphoneEvent>((event, emit) async {
      emit(AuthLoading());

      final result = await authUseCase.loginCellphoneDesktop(
        event.countryCode,
        event.appVer,
        event.deviceId,
        event.requestId,
        event.clientSign,
        event.osVer,
        event.cellphone,
        event.password,
      );

      result.fold(
        (failure) => emit(AuthFailure(failure)),
        (entity) => emit(LoginSuccess(entity)),
      );
    });

    on<AttemptRefreshTokenEvent_Type1>((event, emit) async {
      emit(AuthLoading());

      final result = await authUseCase.refreshToken_Type1(event.id);

      result.fold(
        (failure) => emit(AuthFailure(failure)),
        (_) => emit(RefreshTokenSuccess_Type1()),
      );
    });
    on<AttemptRefreshTokenEvent_Type2>((event, emit) async {
      emit(AuthLoading());

      final result = await authUseCase.refreshToken_Type2(event.id);

      result.fold(
        (failure) => emit(AuthFailure(failure)),
        (message) => emit(RefreshTokenSuccess_Type2(message)),
      );
    });
  }
}
