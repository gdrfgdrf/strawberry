
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import '../animation/animation_combine.dart';
import '../animation/smooth_popup_animation.dart';

class _ToastInstance {
  final Widget widget;

  OverlayEntry? overlayEntry;
  AnimationCombination? combination;

  _ToastInstance(this.widget);

  OverlayEntry buildOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    overlayEntry = OverlayEntry(
      builder: (context) {
        final animation = SmoothPopupAnimation(
          child: Stack(
            children: [
              Positioned(
                width: 256.w,
                height: 128.h,
                left: size.width / 2 - 256.w / 2,
                top: size.height * 2 / 3,
                child: widget,
              ),
            ],
          ),
        );

        AnimationCombination.newBuilder()
            .add(animation)
            .build(
          onReady: (animation) {
            combination = animation;
            animation.forwardAll();
          },
        );

        return animation;
      },
    );
    return overlayEntry!;
  }

  void show(BuildContext context) {
    Overlay.of(context).insert(buildOverlay(context));
  }

  void cancel() {
    if (overlayEntry == null || combination == null) {
      return;
    }
    if (!overlayEntry!.mounted) {
      return;
    }
    combination!.reverseAll();
    combination!.reverseAllCallback = () {
      overlayEntry?.remove();
    };
  }
}

class ToastCenter {
  _ToastInstance? _current;
  Timer? _timer;

  void submit(BuildContext context, Widget widget) {
    if (_current != null) {
      _current!.cancel();
      _current = null;
      _timer?.cancel();
      _timer = null;
    }

    _current = _ToastInstance(widget);
    _current!.show(context);

    _timer = Timer(Duration(milliseconds: 2000), () {
      _current?.cancel();
      _current = null;
    });
  }

}