import 'package:domain/entity/login_result.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/qr_code_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strawberry/bloc/qrcode/qr_code_bloc.dart';

class AttemptTryLoginQrCodeEvent extends QrCodeEvent {
  final String uniKey;

  AttemptTryLoginQrCodeEvent(this.uniKey);
}

class TryLoginQrCodeLoading extends QrCodeLoading {

}

class TryLoginQrCodeSuccess extends QrCodeState {
  final QrCodeResult result;

  TryLoginQrCodeSuccess(this.result);
}

class TryLoginQrCodeFailure extends QrCodeFailure {
  TryLoginQrCodeFailure(super.failure);

}
