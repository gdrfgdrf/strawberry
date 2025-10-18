import 'package:flutter/cupertino.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_expand_animation.dart';
import 'package:widgets/widgets/overlay/overlay_calculation.dart';

import '../../animation/animation_bean.dart';

enum PositionDirection {
  upLeft,
  upRight,
  downLeft,
  downRight,
  leftUp,
  leftDown,
  rightUp,
  rightDown,
}

class AnimatedOverlayEntry {
  final AnimationDirection direction;
  final Widget child;

  final GlobalKey? parentKey;
  final double? infix;
  final PositionDirection? positionDirection;
  final Offset? positionOffset;

  final double? width;
  final double? height;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  final VoidCallback? onCreated;
  final VoidCallback? onDismissed;

  OverlayEntry? overlayEntry;
  AnimationCombination? animationCombination;

  bool shown = false;

  AnimatedOverlayEntry({
    required this.direction,
    required this.child,
    this.parentKey,
    this.infix,
    this.positionDirection,
    this.positionOffset,
    this.width,
    this.height,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.onCreated,
    this.onDismissed,
  });

  void show(BuildContext context) {
    buildOverlay();
    overlayEntry?.addListener(() {
      if (overlayEntry != null) {
        shown = true;
        onCreated?.call();
      } else {
        shown = false;
        onDismissed?.call();
      }
    });
    Overlay.of(context).insert(overlayEntry!);
  }

  void hide() {
    if (animationCombination == null) {
      overlayEntry?.remove();
      overlayEntry = null;
      return;
    }
    animationCombination?.reverseAll();
    animationCombination?.reverseAllCallback = () {
      overlayEntry?.remove();

      overlayEntry = null;
    };
  }

  void dispose() {
    overlayEntry?.dispose();
  }

  void buildOverlay() {
    if (overlayEntry != null) {
      return;
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        double? actualTop = top;
        double? actualLeft = left;
        double? actualRight = right;
        double? actualBottom = bottom;

        if (parentKey != null && width != null && height != null) {
          final calculatedResult = OverlayCalculation.calculatePosition(
            parentKey!,
            width!,
            height!,
            infix: infix,
            positionDirection: positionDirection,
          );
          if (!calculatedResult.isEmpty()) {
            actualTop = calculatedResult.top;
            actualLeft = calculatedResult.left;
            actualRight = calculatedResult.right;
            actualBottom = calculatedResult.bottom;
          }
        }

        final animation = SmoothExpandAnimation(
          duration: Duration(milliseconds: 500),
          axis: direction,
          width: width,
          height: height,
          top: actualTop,
          left: actualLeft,
          right: actualRight,
          bottom: actualBottom,
          child: child,
        );

        AnimationCombination.newBuilder()
            .add(animation)
            .build(
              onReady: (animation) {
                animationCombination = animation;
                animation.forwardAll();
              },
            );

        return animation;
      },
    );
  }
}
