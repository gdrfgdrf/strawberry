import 'package:domain/entity/playlists_entity.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';

abstract class PageRouter {
  FluroRouter getRouter();

  List<RouteDefinition> definitions();

  void initRouter() {
    for (final routeDefinition in definitions()) {
      routeDefinition.define(getRouter());
    }
  }
}

class RouteDefinition {
  final String path;
  final TransitionType transitionType;
  final Duration transitionDuration;
  final Handler handler;

  const RouteDefinition(
    this.path,
    this.transitionType,
    this.transitionDuration,
    this.handler,
  );

  void define(FluroRouter router) {
    router.define(
      path,
      handler: handler,
      transitionType: transitionType,
      transitionDuration: transitionDuration,
    );
  }

  static RouteDefinition of(
    String path,
    Widget Function(BuildContext? context, Map<String, List<String>> parameters)
    buildFunction, {
    TransitionType transitionType = TransitionType.cupertino,
    Duration transitionDuration = FluroRouter.defaultTransitionDuration,
  }) {
    return RouteDefinition(
      path,
      transitionType,
      transitionDuration,
      Handler(handlerFunc: buildFunction),
    );
  }
}

abstract class NavigatorFactory {
  AbstractMainNavigator createMain();

  AbstractHomeNavigator createHome();
}

abstract class AbstractNavigator {
  DartStrawberryServiceLogger? serviceLogger;
  final GlobalKey<NavigatorState> navigatorStateKey;
  final PageRouter router;

  AbstractNavigator(this.navigatorStateKey, this.router) {
    serviceLogger = openService("NavigatorService-$runtimeType");
    serviceLogger!.info("creating: $hashCode");
  }

  void navigateTo(
    String target, {
    bool clearStack = false,
    Object? argument,
  }) {
    serviceLogger!.trace("target: $target, clear stack: $clearStack");

    if (clearStack) {
      navigatorStateKey.currentState?.pushNamedAndRemoveUntil(
        target,
        (_) => false,
        arguments: argument,
      );
      return;
    }
    navigatorStateKey.currentState?.push(
      router.getRouter().generator(
        RouteSettings(name: target, arguments: argument),
      )!,
    );
  }

  void pop(NavigatorState navigatorState) {
    serviceLogger!.trace("pop: $hashCode");
    navigatorState.pop();
  }
}

abstract class AbstractMainNavigator extends AbstractNavigator {
  AbstractMainNavigator(super.navigatorStateKey, super.router);

  void navigateSplash();

  void navigateLogin();

  void navigateHome();
}

abstract class AbstractHomeNavigator extends AbstractNavigator {
  AbstractHomeNavigator(super.navigatorStateKey, super.router);

  void navigatePlaylist(PlaylistItemEntity playlist);
}
