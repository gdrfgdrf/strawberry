import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:natives/ffi/atomic.dart';

import 'controllable_animated_widget.dart';

class AnimationCombination {
  final List<AnimationUnit> _units;
  final ReceivePort _receivePort;
  Function(AnimationCombination)? onReady;
  bool _ready = false;

  VoidCallback? forwardAllCallback;
  VoidCallback? reverseAllCallback;

  AnimationCombination({
    required List<AnimationUnit> units,
    required ReceivePort receivePort,
    this.onReady,
  })
      : _receivePort = receivePort,
        _units = units {
    final readyCount = AtomicApi.createCounter(initial: 0);
    _receivePort.listen((message) {
      if (readyCount.increment() >= _units.length) {
        _receivePort.close();
        readyCount.dispose();
        _ready = true;

        onReady?.call(this);
      }
    });
  }

  void reset(int index) {
    if (!_ready) {
      return;
    }
    return _units.elementAtOrNull(index)?.reset();
  }

  Future<void>? forward(int index) {
    if (!_ready) {
      return null;
    }
    return _units.elementAtOrNull(index)?.forward();
  }

  Future<void>? reverse(int index) {
    if (!_ready) {
      return null;
    }
    return _units.elementAtOrNull(index)?.reverse();
  }

  void resetAll() {
    if (!_ready) {
      return;
    }

    for (final unit in _units) {
      unit.reset();
    }
  }

  List<Future<void>>? forwardAll() {
    if (!_ready) {
      return null;
    }

    int finishedCount = 0;
    List<Future<void>> result = [];

    for (final unit in _units) {
      var tickerFuture = unit.forward();
      if (tickerFuture == null) {
        continue;
      }

      result.add(tickerFuture);
      tickerFuture.whenComplete(() {
        finishedCount++;

        if (finishedCount >= result.length) {
          forwardAllCallback?.call();
        }
      });
    }

    return result;
  }

  List<Future<void>>? reverseAll() {
    if (!_ready) {
      return null;
    }

    int finishedCount = 0;
    List<Future<void>> result = [];

    for (final unit in _units) {
      var tickerFuture = unit.reverse();
      if (tickerFuture == null) {
        continue;
      }

      result.add(tickerFuture);
      tickerFuture.whenComplete(() {
        finishedCount++;

        if (finishedCount >= result.length) {
          reverseAllCallback?.call();
        }
      });
    }

    return result;
  }

  ChainedAnimation chained() {
    return ChainedAnimation(combination: this);
  }

  void disposeAll() {
    for (final unit in _units) {
      unit.dispose();
    }
  }

  static AnimationCombinationBuilder newBuilder() {
    return AnimationCombinationBuilder();
  }
}

class ChainedAnimation {
  final AtomicCounter _currentIndex = AtomicApi.createCounter(initial: 0);
  final AnimationCombination _combination;

  final List<_ChainedUnit> _units = [];

  ChainedAnimation({required AnimationCombination combination})
      : _combination = combination;

  ChainedAnimation forward({
    FutureOr<dynamic> Function(void)? then,
    FutureOr<void> Function(Object?, StackTrace)? onError,
  }) {
    _units.add(_ChainedUnit.of(0, then: then, onError: onError));
    return this;
  }

  ChainedAnimation reverse({
    FutureOr<dynamic> Function(void)? then,
    FutureOr<void> Function(Object?, StackTrace)? onError,
  }) {
    _units.add(_ChainedUnit.of(1, then: then, onError: onError));
    return this;
  }

  Future<void> ready() async {
    for (var unit in _units) {
      final forward = unit.forward;
      final then = unit._then;
      final onError = unit._onError;

      final reverse = forward == 0 ? false : true;
      if (reverse) {
        _currentIndex.decrement();
      }

      final future =
      forward == 0
          ? _combination.forward(_currentIndex.get_())
          : _combination.reverse(_currentIndex.get_());
      await _completeFuture(
        future,
        then,
        onError,
        reverse: forward == 0 ? false : true,
      );
    }
  }

  Future<void> _completeFuture(Future<void>? future,
      FutureOr<dynamic> Function(void)? then,
      FutureOr<void> Function(Object?, StackTrace)? onError, {
        bool reverse = false,
      }) async {
    if (future == null) {
      return;
    }

    await future
        .then((parameter) {
      if (then != null) {
        then(parameter);
      }
      if (!reverse) {
        _currentIndex.increment();
      }
    })
        .catchError((Object error, StackTrace stackTrace) {
      if (!reverse) {
        _currentIndex.decrement();
      } else {
        _currentIndex.increment();
      }

      if (onError != null) {
        onError(error, stackTrace);
      }
    });
  }
}

class _ChainedUnit {
  final int forward;
  final FutureOr<dynamic> Function(void)? _then;
  final FutureOr<void> Function(Object?, StackTrace)? _onError;

  _ChainedUnit._(this.forward, this._then, this._onError);

  static _ChainedUnit of(int forward, {
    FutureOr<dynamic> Function(void)? then,
    FutureOr<void> Function(Object?, StackTrace)? onError,
  }) {
    return _ChainedUnit._(forward, then, onError);
  }
}

class AnimationCombinationBuilder {
  final ReceivePort _mainReceivePort = ReceivePort();
  final List<AnimationUnit> _units = [];

  AnimationCombinationBuilder add(ControllableAnimatedWidget widget) {
    final unit = SingleAnimationUnit.create();
    widget.onControllerCreated = (controller) {
      (unit as SingleAnimationUnit).onControllerCreated(controller);
      _mainReceivePort.sendPort.send(0);
    };

    _units.add(unit);
    return this;
  }

  AnimationCombinationBuilder removeAt(int index) {
    _units.removeAt(index);
    return this;
  }

  AnimationCombinationBuilder group(List<ControllableAnimatedWidget> widgets) {
    final unit = GroupAnimationUnit();
    final targetCount = widgets.length;
    final createdCount = AtomicApi.createCounter(initial: 0);

    for (int i = 0; i < widgets.length; i++) {
      final widget = widgets[i];

      widget.onControllerCreated = (controller) {
        unit.onControllerCreated(widget, controller);
        if (createdCount.increment() >= targetCount) {
          _mainReceivePort.sendPort.send(0);
          createdCount.dispose();
        }
      };
    }

    _units.add(unit);
    return this;
  }

  AnimationCombination build({Function(AnimationCombination)? onReady}) {
    return AnimationCombination(
      units: _units,
      receivePort: _mainReceivePort,
      onReady: onReady,
    );
  }

  int length() {
    return _units.length;
  }
}

abstract class AnimationUnit {
  void reset();

  Future<void>? forward();

  Future<void>? reverse();

  void dispose();
}

class SingleAnimationUnit implements AnimationUnit {
  AnimationController? _controller;

  SingleAnimationUnit._();

  void onControllerCreated(AnimationController controller) {
    _controller = controller;
  }

  @override
  void reset() {
    if (_controller == null) {
      return;
    }
    try {
      return _controller!.reset();
    } catch (e, s) {
      // do nothing
    }
    return;
  }

  @override
  Future<void>? forward() {
    if (_controller == null) {
      return null;
    }
    try {
      return _controller!.forward();
    } catch (e, s) {
      // do nothing
    }
    return null;
  }

  @override
  Future<void>? reverse() {
    if (_controller == null) {
      return null;
    }
    try {
      return _controller!.reverse();
    } catch (e, s) {
      // do nothing
    }
    return null;
  }

  @override
  void dispose() {
    _controller?.dispose();
  }

  static AnimationUnit create() {
    return SingleAnimationUnit._();
  }
}

class GroupAnimationUnit implements AnimationUnit {
  final List<ControllableAnimatedWidget> _widgets = [];
  final List<AnimationController> _controllers = [];

  void onControllerCreated(ControllableAnimatedWidget widget,
      AnimationController controller,) {
    _widgets.add(widget);
    _controllers.add(controller);
  }

  @override
  void reset() {
    if (!_check()) {
      return;
    }
    for (var controller in _controllers) {
      controller.reset();
    }
  }

  @override
  Future<void>? forward() {
    if (!_check()) {
      return null;
    }

    final completer = Completer();

    var finishCount = AtomicApi.createCounter(initial: 0);
    for (var controller in _controllers) {
      try {
        controller.forward().whenComplete(() {
          if (finishCount.increment() >= _controllers.length) {
            completer.complete();
            finishCount.dispose();
          }
        });
      } catch (e, s) {
        // do nothing
      }
    }

    return completer.future;
  }

  @override
  Future<void>? reverse() {
    if (!_check()) {
      return null;
    }

    final completer = Completer();

    var finishCount = AtomicApi.createCounter(initial: 0);
    for (var controller in _controllers) {
      try {
        controller.reverse().whenComplete(() {
          if (finishCount.increment() >= _controllers.length) {
            completer.complete();
            finishCount.dispose();
          }
        });
      } catch (e, s) {
        // do nothing
      }
    }

    return completer.future;
  }

  bool _check() {
    return _widgets.length == _controllers.length;
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
  }
}
