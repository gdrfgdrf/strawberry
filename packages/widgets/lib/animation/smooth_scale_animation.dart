import 'package:flutter/cupertino.dart';
import 'package:widgets/animation/controllable_animated_widget.dart';

import 'animation_bean.dart';

class SmoothScaleAnimation extends ControllableAnimatedWidget {
  final Widget child;
  final Duration duration;
  final ScaleRatio ratio;
  final OpacityTarget? opacityTarget;

  SmoothScaleAnimation({
    super.key,
    required this.child,
    required this.duration,
    required this.ratio,
    this.opacityTarget,
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
    final opacity = Tween(
      begin: opacityTarget?.before ?? 0.0,
      end: opacityTarget?.after ?? 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );
    final scale = Tween(begin: ratio.before, end: ratio.after).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );

    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(scale: scale, child: child),
    );
  }
}
