
import 'package:domain/entity/login_result.dart';
import 'package:shared/api/device.dart';
import 'package:strawberry/bloc/auth/auth_bloc.dart';

class AttemptLoginCellphoneEvent extends AuthEvent {
  final String countryCode;
  final String appVer;
  final String deviceId;
  final String requestId;
  final ClientSign clientSign;
  final String osVer;
  final String cellphone;
  final String password;

  AttemptLoginCellphoneEvent({
    required this.countryCode,
    required this.appVer,
    required this.deviceId,
    required this.requestId,
    required this.clientSign,
    required this.osVer,
    required this.cellphone,
    required this.password,
  });
}

class LoginSuccess extends AuthState {
  final LoginResult result;

  LoginSuccess(this.result);
}