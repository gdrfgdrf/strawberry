import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:strawberry/ui/abstract_delegate.dart';
import 'package:strawberry/ui/abstract_secondary_delegate.dart';

abstract class AbstractWidgetProviderFactory<
  D extends AbstractDelegate,
  D2 extends AbstractSecondaryDelegate
> {
  final D primaryDelegate;
  final List<AbstractWidgetProvider<D, D2>> providers = [];

  AbstractWidgetProviderFactory(this.primaryDelegate);

  String identifier();

  AbstractWidgetProvider<D, D2> createImpl(dynamic parameter);

  AbstractWidgetProvider<D, D2> createDoNotOverride(dynamic parameter) {
    final result = createImpl(parameter);
    postCreate(result);
    return result;
  }

  void postCreate(AbstractWidgetProvider<D, D2> provider) {
    providers.add(provider);
    primaryDelegate.postWidgetCreated(provider);
  }

  void disposeAll() {
    for (final provider in providers) {
      provider.dispose();
    }
  }
}

abstract class AbstractWidgetProvider<
  D extends AbstractDelegate,
  D2 extends AbstractSecondaryDelegate
> {
  DartStrawberryServiceLogger? serviceLogger;

  final D primaryDelegate;
  D2? delegate;

  AbstractWidgetProvider(this.primaryDelegate) {
    delegate = createDelegate();
  }

  D2 createDelegate();

  List<VoidCallback> postListeners() => [];

  List<VoidCallback> reusePostListeners() => [];

  List<BlocListener> blocListeners() => [];

  Widget provideImpl(BuildContext context);

  void dispose() {
    delegate?.dispose();
  }
}
