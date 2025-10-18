
import 'package:domain/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import 'main_router.dart';

class MainNavigatorImpl extends AbstractMainNavigator {
  MainNavigatorImpl(super.navigatorStateKey, super.router);

  @override
  void navigateLogin() {
    navigateTo("/login", clearStack: true);
  }

  @override
  void navigateSplash() {
    navigateTo("/splash");
  }

  @override
  void navigateHome() {
    navigateTo("/home", clearStack: true);
  }
}