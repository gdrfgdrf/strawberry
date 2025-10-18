
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';

abstract class AbstractSecondaryDelegate {
  BuildContext? context;
  void Function(void Function())? setState;
  DartStrawberryServiceLogger? serviceLogger;

  final Map<Type, BlocBase> blocs = {};
  final List<BlocListener> blocListeners = [];

  AbstractSecondaryDelegate() {
    serviceLogger = openService("UiSecondaryService-$runtimeType");
    serviceLogger!.info("creating: $hashCode");
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
    serviceLogger!.trace("disposing: $hashCode");

    for (final bloc in blocs.values) {
      bloc.close();
    }
    blocs.clear();
  }
}