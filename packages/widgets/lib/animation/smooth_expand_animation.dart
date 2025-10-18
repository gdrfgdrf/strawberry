import 'package:flutter/material.dart';
import 'package:shared/themes.dart';
import 'package:widgets/animation/controllable_animated_widget.dart';

import 'animation_bean.dart';

class ExpandClipper extends CustomClipper<Rect> {
  final AnimationDirection axis;
  final double factor;

  const ExpandClipper(this.axis, this.factor);

  @override
  Rect getClip(Size size) {
    switch (axis) {
      case AnimationDirection.verticalTopToBottom:
        return Rect.fromLTRB(0, 0, size.width, size.height * factor);
      case AnimationDirection.verticalBottomToTop:
        return Rect.fromLTRB(
          0,
          size.height * (1 - factor),
          size.width,
          size.height,
        );
      case AnimationDirection.horizontalLeftToRight:
        return Rect.fromLTRB(0, 0, size.width * factor, size.height);
      case AnimationDirection.horizontalRightToLeft:
        return Rect.fromLTRB(
          size.width * (1 - factor),
          0,
          size.width,
          size.height,
        );
    }
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class SmoothExpandAnimation extends ControllableAnimatedWidget {
  final Widget child;
  final AnimationDirection axis;
  final Duration duration;

  final double? width;
  final double? height;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  SmoothExpandAnimation({
    super.key,
    required this.child,
    required this.axis,
    required this.duration,
    this.width,
    this.height,
    this.top,
    this.left,
    this.right,
    this.bottom,
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
    final animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Stack(
            children: [
              Positioned(
                width: width,
                height: height,
                top: top,
                left: left,
                right: right,
                bottom: bottom,
                child: ClipRect(
                  clipper: ExpandClipper(axis, animation.value),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: this.child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
