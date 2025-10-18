import 'package:flutter/cupertino.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:widgets/animation/controllable_animated_widget.dart';
import 'package:widgets/animation/smooth_scale_animation.dart';

import 'animation_bean.dart';

/// 使用该组件时需要注意：若 Widget 的切换是连续的，
/// 比如 A(before: SizedBox.shrink(), after: A) ->
/// B(before: A, after: B) ->
/// C(before: B, after: C)，
/// 那么在每次切换前需要设置 forwardCallback，内容为设置 before 为 null
/// 否则 Widget 树将会出现多个 before
class SmoothWidgetSwitchAnimation extends ControllableAnimatedWidget {
  final Widget before;
  final Widget after;
  final Duration duration;
  final AlignmentDirectional alignment;

  ValueNotifier<Widget?>? _beforeWidgetNotifier;

  SmoothWidgetSwitchAnimation({
    super.key,
    required this.before,
    required this.after,
    required this.duration,
    this.alignment = AlignmentDirectional.center
  });

  @override
  AnimationController createController(TickerProvider vsync) {
    return AnimationController(duration: duration, vsync: vsync)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _beforeWidgetNotifier!.value = null;
      }
    });
  }

  @override
  Widget buildAnimatedWidget(
    BuildContext context,
    AnimationController controller,
  ) {
    Widget? outAnimation = SmoothScaleAnimation(
      duration: duration,
      ratio: ScaleRatio(1.0, 0.8),
      opacityTarget: OpacityTarget(1.0, 0.0),
      child: before,
    ).buildAnimatedWidget(context, controller);
    final inAnimation = SmoothScaleAnimation(
      duration: duration,
      ratio: ScaleRatio(0.8, 1.0),
      opacityTarget: OpacityTarget(0.0, 1.0),
      child: after,
    ).buildAnimatedWidget(context, controller);

    _beforeWidgetNotifier = ValueNotifier(outAnimation);
    return ValueListenableBuilder(valueListenable: _beforeWidgetNotifier!, builder: (_, beforeWidget, _) {
      if (beforeWidget == null) {
        outAnimation = null;
      }

      return Stack(
        alignment: alignment,
        children: [
          beforeWidget ?? SizedBox.shrink(),
          inAnimation
        ],
      );
    });
  }
}