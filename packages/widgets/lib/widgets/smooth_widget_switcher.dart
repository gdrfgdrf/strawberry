import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class WidgetSwitcherController {
  final BehaviorSubject<Widget?> stream = BehaviorSubject.seeded(null);

  void switchPermanently(Widget? target) {
    stream.add(target);
  }

  void switchTemporary(
    Widget? target, {
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    Widget? previous = stream.valueOrNull;

    stream.add(target);

    Timer(duration, () {
      if (stream.isClosed) {
        return;
      }
      switchPermanently(previous);
    });
  }

  void switchProgressIndicator() {
    switchPermanently(CircularProgressIndicator());
  }

  void dispose() {
    stream.close();
  }
}

class SmoothWidgetSwitcher extends StatefulWidget {
  final WidgetSwitcherController controller;
  final Widget? initial;

  const SmoothWidgetSwitcher({super.key, required this.controller, this.initial});

  @override
  State<StatefulWidget> createState() => _SmoothWidgetSwitcherState();
}

class _SmoothWidgetSwitcherState extends State<SmoothWidgetSwitcher> {
  StreamSubscription? subscription;
  bool initialUsed = false;

  @override
  void initState() {
    super.initState();
    subscription = widget.controller.stream.listen((widgetSwitch) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initial != null && !initialUsed) {
      initialUsed = true;
      return widget.initial!;
    }

    Widget target = widget.controller.stream.valueOrNull ?? SizedBox.shrink();
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      switchInCurve: Curves.fastEaseInToSlowEaseOut,
      switchOutCurve: Curves.fastEaseInToSlowEaseOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: target,
    );
  }
}
