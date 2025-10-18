import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared/themes.dart';
import 'package:widgets/animation/animation_bean.dart';
import 'package:widgets/animation/controllable_animated_widget.dart';

class SmoothBlurAnimation extends ControllableAnimatedWidget {
  final Widget child;
  final BlurTarget blurTarget;
  final Duration duration;
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final double blurRadius;

  SmoothBlurAnimation({
    super.key,
    required this.child,
    required this.blurTarget,
    required this.duration,
    required this.width,
    required this.height,
    this.borderRadius,
    this.blurRadius = 20.0,
  });

  @override
  AnimationController createController(TickerProvider vsync) {
    return AnimationController(duration: duration, vsync: vsync);
  }

  @override
  Widget buildAnimatedWidget(
    BuildContext context,
    AnimationController controller,
  ) {
    final blurAnimation = Tween(
      begin: blurTarget.before,
      end: blurTarget.after,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(0),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurAnimation.value,
              sigmaY: blurAnimation.value,
            ),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(borderRadius: borderRadius),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
