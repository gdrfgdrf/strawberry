import 'package:domain/navigation_service.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:strawberry/nextui/login/qr_code_login_screen.dart';
import 'package:strawberry/ui/home/home_page.dart';
import 'package:strawberry/ui/login/root_login_page.dart';
import 'package:strawberry/ui/profile/profile_page.dart';
import 'package:strawberry/ui/splash_page.dart';

class MainRouter extends PageRouter {
  FluroRouter router = FluroRouter();

  RouteDefinition splash1 = RouteDefinition.of(
    "/",
        (_, __) => SplashPage(),
    transitionType: TransitionType.cupertino,
  );

  RouteDefinition splash2 = RouteDefinition.of(
    "/splash",
    (_, __) => SplashPage(),
  );
  RouteDefinition login = RouteDefinition.of(
    "/login",
    (_, __) => QrCodeLoginScreen(),
    transitionType: TransitionType.fadeIn,
    transitionDuration: Duration(milliseconds: 1000),
  );
  RouteDefinition home = RouteDefinition.of(
    "/home",
    (_, __) => HomePage(),
    transitionType: TransitionType.fadeIn,
    transitionDuration: Duration(milliseconds: 1000),
  );

  @override
  List<RouteDefinition> definitions() {
    return [
      splash1,
      splash2,
      login,
      home
    ];
  }

  @override
  FluroRouter getRouter() {
    return router;
  }
}