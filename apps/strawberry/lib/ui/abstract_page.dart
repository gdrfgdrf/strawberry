import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';

import 'abstract_delegate.dart';

class EmptyDelegate extends AbstractDelegate {
  static final EmptyDelegate instance = EmptyDelegate();
}

abstract class AbstractUiWidget extends StatefulWidget {
  const AbstractUiWidget({super.key});
}

abstract class AbstractUiWidgetState<
  T extends AbstractUiWidget,
  D extends AbstractDelegate
>
    extends State<T> {
  DartStrawberryServiceLogger? serviceLogger;

  D? delegate;

  D createDelegate();

  void delegateReady() {}

  Widget buildContent(BuildContext context);

  List<VoidCallback> postListeners() => [];

  List<VoidCallback> reusePostListeners() => [];

  List<BlocListener> blocListeners() => [];

  AbstractUiWidgetState() {
    serviceLogger = openService("UiService-$runtimeType");
    serviceLogger!.info("creating: $hashCode");
  }

  @override
  void initState() {
    super.initState();
    serviceLogger!.trace("creating delegate: $hashCode");
    delegate = createDelegate();
    delegate!.context = context;
    delegate!.setState = setState;
    delegateReady();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      delegate!.invokePostListeners(postListeners());
    });
  }

  @override
  Widget build(BuildContext context) {
    serviceLogger!.trace("building page: $hashCode");

    delegate!.beforeBuild();

    buildSelf();

    Widget content = buildContent(context);
    final mergedBlocListeners = delegate!.mergeBlocListeners(blocListeners());
    if (mergedBlocListeners.isNotEmpty) {
      content = MultiBlocListener(
        listeners: mergedBlocListeners,
        child: content,
      );
    }

    return content;
  }

  void buildSelf() {
    delegate!.updateContext(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      delegate!.invokeReusePostListeners(reusePostListeners());
    });
  }

  @override
  void dispose() {
    serviceLogger!.info("disposing: $hashCode");

    delegate!.dispose();
    delegate = null;
    serviceLogger = null;
    super.dispose();
  }
}
