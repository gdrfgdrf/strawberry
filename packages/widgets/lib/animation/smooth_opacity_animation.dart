import 'package:flutter/cupertino.dart';
import 'package:widgets/animation/controllable_animated_widget.dart';
import 'package:widgets/animation/smooth_blur_animation.dart';

import 'animation_bean.dart';

class SmoothOpacityAnimation extends ControllableAnimatedWidget {
  final Widget child;
  final OpacityTarget opacityTarget;

  final BlurTarget blurTarget;
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final double blurRadius;

  final Duration duration;

  SmoothOpacityAnimation({
    super.key,
    required this.child,
    required this.opacityTarget,
    required this.blurTarget,
    required this.width,
    required this.height,
    this.borderRadius,
    this.blurRadius = 20,
    required this.duration,
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
    final blurAnimation = SmoothBlurAnimation(
      blurTarget: blurTarget,
      duration: duration,
      width: width,
      height: height,
      borderRadius: borderRadius,
      blurRadius: blurRadius,
      child: child,
    ).buildAnimatedWidget(context, controller);

    final tween = Tween(
      begin: opacityTarget.before,
      end: opacityTarget.after,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );

    return FadeTransition(opacity: tween, child: blurAnimation);
  }
}
