import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/configuration/desktop_config.dart';
import 'package:shared/configuration/general_config.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/bloc/auth/auth_bloc.dart';
import 'package:strawberry/ui/abstract_delegate.dart';
import 'package:strawberry/ui/login/root_login_page.dart';
import 'package:widgets/animation/animation_combine.dart';

import '../../bloc/auth/refresh_token_event_state.dart';
import '../../bloc/auth/register_anonimous_event_state.dart';

class RootLoginPageDelegate extends AbstractDelegate {
  bool cookiePrepared = false;
  bool cookiePreparedFromCache = false;
  bool tokenRefreshTried = false;

  AuthBloc authBloc = GetIt.instance.get();

  LoginType? loginType;
  LoginType? previousLoginType;

  AnimationCombination? mainSwitchAnimation;
  int animationUpdateKey = 0;

  List<Widget> pages = [];
  PageController? pageController;

  RootLoginPageDelegate() {
    registerBloc(authBloc);
  }

  void onCookiePrepared() {
    cookiePrepared = true;
    if (!cookiePreparedFromCache) {
      mainSwitchAnimation?.forwardAll();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mainSwitchAnimation?.forwardAll();
    });

    refreshToken();
  }

  void refreshToken() {
    if (tokenRefreshTried) {
      return;
    }
    final generalConfig = GetIt.instance.get<GeneralConfig>();
    authBloc.add(AttemptRefreshTokenEvent_Type1(generalConfig.lastLoginId));
  }

  void prepareCookie() async {
    if (cookiePrepared) {
      return;
    }

    final desktopConfig = GetIt.instance.get<DesktopConfig>();
    final device = desktopConfig.device;

    authBloc.add(
      AttemptRegisterAnonimousEvent(deviceId: device.deviceId),
    );
  }

  void onPageChanged(int page) {
    previousLoginType = loginType;

    if (page == 0) {
      loginType = LoginType.cellphone;
    } else {
      loginType = LoginType.qrCode;
    }

    animationUpdateKey++;

    setState!(() {});
  }

  void onFloatingActionButtonPressed() {
    if (loginType == LoginType.cellphone) {
      pageController?.animateToPage(
        1,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    } else {
      pageController?.animateToPage(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    }
  }
}
