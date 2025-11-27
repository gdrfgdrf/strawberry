import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// 直接照抄的 AnimatedOpacity
class AnimatedBlur extends ImplicitlyAnimatedWidget {
  final Widget? child;
  final double value;
  final BorderRadius? borderRadius;

  const AnimatedBlur({
    super.key,
    this.child,
    this.borderRadius,
    super.curve,
    super.onEnd,
    required this.value,
    required super.duration,
  });

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AnimatedBlurState();
}

class _AnimatedBlurState extends ImplicitlyAnimatedWidgetState<AnimatedBlur> {
  Tween<double>? _value;
  late Animation<double> _animation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _value =
        visitor(
              _value,
              widget.value,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  void didUpdateTweens() {
    _animation = animation.drive(_value!);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: _animation.value,
            sigmaY: _animation.value,
          ),
          child: widget.child,
        );
      },
    );
  }
}
