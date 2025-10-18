import 'package:flutter/cupertino.dart';
import 'package:widgets/animation/controllable_animated_widget.dart';

class SmoothPopupAnimation extends ControllableAnimatedWidget {
  final Widget child;
  final Duration duration;

  SmoothPopupAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  AnimationController createController(TickerProvider vsync) {
    return AnimationController(vsync: vsync, duration: duration);
  }

  @override
  Widget buildAnimatedWidget(
    BuildContext context,
    AnimationController controller,
  ) {
    final scaleAnimation = Tween(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );
    final opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnimation, opacityAnimation]),
      builder: (context, _) {
        return Opacity(
          opacity: opacityAnimation.value,
          child: Transform.scale(scale: scaleAnimation.value, child: child),
        );
      },
    );
  }
}
