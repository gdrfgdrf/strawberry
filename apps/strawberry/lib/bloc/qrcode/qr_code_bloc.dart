import 'dart:io';

import 'package:domain/result/result.dart';
import 'package:domain/usecase/qr_code_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strawberry/bloc/qrcode/try_login_qr_code_event_state.dart';

import '../strawberry_bloc.dart';
import 'get_qr_code_unikey_event_state.dart';

abstract class QrCodeEvent {}

abstract class QrCodeState {}

class QrCodeInitial extends QrCodeState {}

class QrCodeLoading extends QrCodeState {}

class QrCodeFailure extends QrCodeState {
  final Failure failure;

  QrCodeFailure(this.failure);
}

class QrCodeBloc
    extends StrawberryBloc<QrCodeEvent, QrCodeState> {
  final QrCodeUseCase qrCodeUseCase;

  QrCodeBloc(this.qrCodeUseCase) : super(QrCodeInitial()) {
    on<AttemptGetOrCodeUniKeyEvent>((event, emit) async {
      emit(QrCodeLoading());

      final result = await qrCodeUseCase.getUniKey();

      result.fold(
        (failure) => emit(QrCodeFailure(failure)),
        (uniKey) => emit(GetQrCodeUniKeySuccess(uniKey)),
      );
    });

    on<AttemptTryLoginQrCodeEvent>((event, emit) async {
      emit(TryLoginQrCodeLoading());

      final result = await qrCodeUseCase.tryLogin(event.uniKey);
      result.fold(
            (failure) => emit(TryLoginQrCodeFailure(failure)),
            (result) => emit(TryLoginQrCodeSuccess(result)),
      );
    });
  }
}
