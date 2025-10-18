import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:strawberry/ui/abstract_widget_provider.dart';

abstract class AbstractDelegate {
  BuildContext? context;
  void Function(void Function())? setState;

  final Map<Type, BlocBase> blocs = {};
  final Map<String, AbstractWidgetProviderFactory> _widgetProviderFactories =
      {};
  final Map<String, AbstractWidgetProvider> widgetProvidersCache = {};
  final List<VoidCallback> postListeners = [];
  final List<VoidCallback> reusePostListeners = [];
  final List<BlocListener> blocListeners = [];
  DartStrawberryServiceLogger? serviceLogger;

  AbstractDelegate() {
    serviceLogger = openService("UiDelegateService-$runtimeType");
    serviceLogger!.info("creating: $hashCode");

    buildWidgetProviderFactories();
  }

  List<AbstractWidgetProviderFactory> widgetProviderFactories() => [];

  List<BlocListener> mergeBlocListeners(List<BlocListener> list) {
    serviceLogger!.trace("merging bloc listeners: $hashCode");
    return list..addAll(blocListeners);
  }

  AbstractWidgetProviderFactory getWidgetProviderFactory(String identifier) {
    serviceLogger!.trace(
      "getting widget provider factory, identifier: $identifier: $hashCode",
    );

    if (context == null) {
      throw ArgumentError("build context is not gained");
    }
    if (!_widgetProviderFactories.containsKey(identifier)) {
      throw ArgumentError("cannot find any providers named $identifier: $hashCode");
    }
    return _widgetProviderFactories[identifier]!;
  }

  Widget getWidget(String identifier, {dynamic parameter, bool cache = true}) {
    serviceLogger!.trace(
      "providing widget, identifier: $identifier, cache: $cache: $hashCode",
    );

    if (cache && widgetProvidersCache.containsKey(identifier)) {
      return widgetProvidersCache[identifier]!.provideImpl(context!);
    }

    final result = getWidgetProviderFactory(
      identifier,
    ).createDoNotOverride(parameter);
    if (cache) {
      widgetProvidersCache[identifier] = result;
    }

    return result.provideImpl(context!);
  }

  void buildWidgetProviderFactories() {
    serviceLogger!.trace("building widget provider factories: $hashCode");

    _widgetProviderFactories.clear();
    postListeners.clear();
    reusePostListeners.clear();
    blocListeners.clear();
    widgetProvidersCache.clear();

    for (final factory in widgetProviderFactories()) {
      final identifier = factory.identifier();
      serviceLogger!.trace(
        "build widget provider factory, identifier: $identifier: $hashCode",
      );

      _widgetProviderFactories[identifier] = factory;
    }
  }

  void postWidgetCreated(AbstractWidgetProvider provider) {
    serviceLogger!.trace("widget created post: $hashCode");

    postListeners.addAll(provider.postListeners());
    reusePostListeners.addAll(provider.reusePostListeners());
    blocListeners.addAll(provider.blocListeners());
  }

  void invokePostListeners(List<VoidCallback> primaryDelegatePostListeners) {
    serviceLogger!.trace("invoking post listeners: $hashCode");

    for (final postListener in primaryDelegatePostListeners) {
      postListener();
    }
    for (final postListener in postListeners) {
      postListener();
    }
  }

  void invokeReusePostListeners(
    List<VoidCallback> primaryDelegateReusePostListeners,
  ) {
    serviceLogger!.trace("invoking reuse post listeners: $hashCode");

    for (final postListener in primaryDelegateReusePostListeners) {
      postListener();
    }
    for (final postListener in reusePostListeners) {
      postListener();
    }
  }

  void beforeBuild() {
    serviceLogger!.trace("before building: $hashCode");

    postListeners.clear();
    reusePostListeners.clear();
    blocListeners.clear();
  }

  void updateContext(BuildContext context) {
    serviceLogger!.trace("updating context: $hashCode");
    this.context = context;
  }

  void registerBloc<B extends BlocBase>(B bloc) {
    serviceLogger!.trace("registering bloc: ${bloc.runtimeType}: $hashCode");
    blocs[B] = bloc;
  }

  void dispose() {
    serviceLogger!.info("disposing: $hashCode");

    for (final bloc in blocs.values) {
      bloc.close();
    }
    blocs.clear();
    for (final factory in _widgetProviderFactories.values) {
      factory.disposeAll();
    }

    _widgetProviderFactories.clear();
    postListeners.clear();
    reusePostListeners.clear();
    blocListeners.clear();
    widgetProvidersCache.clear();
  }
}
