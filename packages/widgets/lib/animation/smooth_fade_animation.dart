import 'package:flutter/cupertino.dart';
import 'package:widgets/animation/animation_bean.dart';
import 'package:widgets/animation/controllable_animated_widget.dart';

class SmoothFadeInAnimation extends ControllableAnimatedWidget {
  final Widget child;
  final Duration duration;
  final OpacityTarget opacityTarget;
  final AnimationDirection direction;
  final double slideOffset;

  SmoothFadeInAnimation({
    super.key,
    required this.child,
    required this.duration,
    this.opacityTarget = const OpacityTarget(0.0, 1.0),
    this.direction = AnimationDirection.verticalTopToBottom,
    this.slideOffset = 50,
  });

  @override
  AnimationController createController(TickerProvider vsync) {
    return AnimationController(duration: duration, vsync: vsync);
  }

  Widget buildAnimatedWidgetWithAnimation(
    BuildContext context,
    Animation<double> animation,
  ) {
    final opacityAnimation = Tween(
      begin: opacityTarget.before,
      end: opacityTarget.after,
    ).animate(animation);
    final offsetAnimation = Tween(
      begin: slideOffset,
      end: 0.0,
    ).animate(animation);

    return FadeTransition(
      opacity: opacityAnimation,
      child: AnimatedBuilder(
        animation: offsetAnimation,
        builder: (_, __) {
          Offset offset;

          switch (direction) {
            case AnimationDirection.verticalTopToBottom:
              {
                offset = Offset(0, -offsetAnimation.value);
              }
            case AnimationDirection.verticalBottomToTop:
              {
                offset = Offset(0, offsetAnimation.value);
              }
            case AnimationDirection.horizontalLeftToRight:
              {
                offset = Offset(-offsetAnimation.value, 0);
              }
            case AnimationDirection.horizontalRightToLeft:
              {
                offset = Offset(offsetAnimation.value, 0);
              }
          }
          return Transform.translate(offset: offset, child: child);
        },
      ),
    );
  }

  @override
  Widget buildAnimatedWidget(
    BuildContext context,
    AnimationController controller,
  ) {
    return buildAnimatedWidgetWithAnimation(
      context,
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );
  }
}

class SmoothFadeOutAnimation extends ControllableAnimatedWidget {
  final Widget child;
  final Duration duration;
  final OpacityTarget opacityTarget;
  final AnimationDirection direction;
  final double slideOffset;

  SmoothFadeOutAnimation({
    super.key,
    required this.child,
    required this.duration,
    this.opacityTarget = const OpacityTarget(1.0, 0.0),
    this.direction = AnimationDirection.verticalTopToBottom,
    this.slideOffset = 50,
  });

  @override
  AnimationController createController(TickerProvider vsync) {
    return AnimationController(duration: duration, vsync: vsync);
  }

  Widget buildAnimatedWidgetWithAnimation(
    BuildContext context,
    Animation<double> animation,
  ) {
    final opacityAnimation = Tween(
      begin: opacityTarget.before,
      end: opacityTarget.after,
    ).animate(animation);
    final offsetAnimation = Tween(
      begin: 0.0,
      end: slideOffset,
    ).animate(animation);

    return FadeTransition(
      opacity: opacityAnimation,
      child: AnimatedBuilder(
        animation: offsetAnimation,
        builder: (_, __) {
          Offset offset;

          switch (direction) {
            case AnimationDirection.verticalTopToBottom:
              {
                offset = Offset(0, offsetAnimation.value);
              }
            case AnimationDirection.verticalBottomToTop:
              {
                offset = Offset(0, -offsetAnimation.value);
              }
            case AnimationDirection.horizontalLeftToRight:
              {
                offset = Offset(offsetAnimation.value, 0);
              }
            case AnimationDirection.horizontalRightToLeft:
              {
                offset = Offset(-offsetAnimation.value, 0);
              }
          }
          return Transform.translate(offset: offset, child: child);
        },
      ),
    );
  }

  @override
  Widget buildAnimatedWidget(
    BuildContext context,
    AnimationController controller,
  ) {
    return buildAnimatedWidgetWithAnimation(
      context,
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );
  }
}
