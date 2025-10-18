
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/api/device.dart';
import 'package:shared/configuration/desktop_config.dart';
import 'package:shared/l10n/localizer.dart';
import 'package:shared/platform_extension.dart';
import 'package:shared/string_extension.dart';
import 'package:strawberry/bloc/auth/auth_bloc.dart';
import 'package:strawberry/ui/abstract_delegate.dart';

import '../../bloc/auth/login_event_state.dart';

class CellphoneLoginPageDelegate extends AbstractDelegate {
  AuthBloc authBloc = GetIt.instance.get();

  int countryCode = 86;
  String? cellphone;
  String? password;

  CellphoneLoginPageDelegate() {
    registerBloc(authBloc);
  }

  void attemptLogin(BuildContext context) {
    if (cellphone == null ||
        password == null ||
        cellphone!.isBlank() ||
        password!.isBlank()) {
      return;
    }
    final desktopConfig = GetIt.instance.get<DesktopConfig>();
    final device = desktopConfig.device;
    final client = desktopConfig.client;
    final clientSign = desktopConfig.clientSign;

    authBloc.add(
      AttemptLoginCellphoneEvent(
        countryCode: countryCode.toString(),
        appVer: client.appVer,
        deviceId: device.deviceId,
        requestId: CodeGenerator.generateRequestId(),
        clientSign: clientSign,
        osVer: device.osVer,
        cellphone: cellphone!,
        password: password!,
      ),
    );
  }
}