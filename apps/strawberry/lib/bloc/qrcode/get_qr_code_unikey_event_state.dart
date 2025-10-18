import 'package:strawberry/bloc/qrcode/qr_code_bloc.dart';

class AttemptGetOrCodeUniKeyEvent extends QrCodeEvent {}

class GetQrCodeUniKeySuccess extends QrCodeState {
  final String uniKey;

  GetQrCodeUniKeySuccess(this.uniKey);
}