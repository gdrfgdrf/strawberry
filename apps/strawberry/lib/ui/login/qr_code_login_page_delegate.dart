import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shared/l10n/localizer.dart';
import 'package:strawberry/ui/abstract_delegate.dart';
import 'package:widgets/animation/animation_bean.dart';

import '../../bloc/qrcode/get_qr_code_unikey_event_state.dart';
import '../../bloc/qrcode/qr_code_bloc.dart';
import '../../bloc/qrcode/try_login_qr_code_event_state.dart';
import '../../bloc/user/get_user_detail_event_state.dart';
import '../../bloc/user/user_bloc.dart';

class QrCodeLoginPageDelegate extends AbstractDelegate {
  QrCodeBloc qrcodeBloc = GetIt.instance.get();
  UserBloc userBloc = GetIt.instance.get();

  String? uniKey;
  QrImage? previous;
  QrImage? current;
  Widget? overlay;
  bool tryLoginTaskRunning = false;

  ValueNotifier<QrImage?> qrImageNotifier = ValueNotifier(null);
  ValueNotifier<bool> blurState = ValueNotifier(false);
  ValueNotifier<Widget> upNotifier = ValueNotifier(CircularProgressIndicator());

  QrCodeLoginPageDelegate() {
    registerBloc(qrcodeBloc);
    registerBloc(userBloc);
  }

  void getUserDetail_Type1(int userId) {
    userBloc.add(AttemptGetUserDetailEvent_Type1(userId, isLogin: true));
  }

  void getUserDetail_Type2() {
    userBloc.add(AttemptGetUserDetailEvent_Type2(isLogin: true));
  }

  void tryLogin() {
    if (uniKey == null || tryLoginTaskRunning) {
      return;
    }
    tryLoginTaskRunning = true;
    qrcodeBloc.add(AttemptTryLoginQrCodeEvent(uniKey!));
  }

  void generateQrCode() {
    uniKey = null;
    qrcodeBloc.add(AttemptGetOrCodeUniKeyEvent());
  }

  void onGetQrCodeUniKeySuccess(GetQrCodeUniKeySuccess state) {
    uniKey = state.uniKey;

    final qrCode = QrCode(8, QrErrorCorrectLevel.L);
    qrCode.addData("https://music.163.com/login?codekey=$uniKey");
    qrImageNotifier.value = QrImage(qrCode);
    blurState.value = false;

    tryLogin();
  }

  void onTryLoginQrCodeSuccess(TryLoginQrCodeSuccess state) {
    final result = state.result;

    if (result.isExpired()) {
      generateQrCode();
      return;
    }
    if (result.isAuthorizing()) {
      upNotifier.value = Text(Localizer.of(context!)!.qr_code_authorizing);
      blurState.value = true;
    }
    if (result.isAuthorized()) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text("Authorized", textAlign: TextAlign.center)),
      );

      getUserDetail_Type2();
    }
    if (result.isError()) {
      generateQrCode();
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text(
            Localizer.of(context!)!.qr_code_error(result.message),
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }
    if (result.needNextCheck()) {
      Timer(Duration(milliseconds: 1000), () {
        tryLogin();
      });
    }
  }

  @override
  void dispose() {
    qrImageNotifier.dispose();
    blurState.dispose();
    upNotifier.dispose();
    super.dispose();
  }
}
