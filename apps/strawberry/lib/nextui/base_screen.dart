
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:widgets/widgets/an_error_widget.dart';
import 'package:widgets/widgets/no_data_widget.dart';

abstract class BaseWidget extends StatefulWidget {

}

abstract class BaseWidgetState extends State<BaseWidget> with WidgetsBindingObserver {
  Size? screenSize;
  EdgeInsets? safeAreaInsets;
  Orientation? orientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    onStateCreate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onStateReady();
    });
  }

  @protected
  void onStateCreate() {}

  @protected
  void onStateReady() {}

  @protected
  void onPostFrame() {}

  @protected
  void onStateDestroy() {}

  @protected
  Widget buildContent(BuildContext context);

  @override
  void didChangeMetrics() {
    if (mounted) {
      setState(() {
        screenSize = MediaQuery.of(context).size;
        orientation = MediaQuery.of(context).orientation;
        safeAreaInsets = MediaQuery.of(context).padding;
      });
    }
  }

  @protected
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onStateDestroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    orientation = MediaQuery.of(context).orientation;
    safeAreaInsets = MediaQuery.of(context).padding;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onPostFrame();
    });
    return buildContent(context);
  }

}