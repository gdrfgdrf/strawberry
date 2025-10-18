import 'package:flutter/cupertino.dart';
import 'package:widgets/animation/smooth_widget_switch_animation.dart';

class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedListItem({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<StatefulWidget> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Widget? animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: widget.duration);
    animation = SmoothWidgetSwitchAnimation(
      before: SizedBox.shrink(),
      after: widget.child,
      duration: widget.duration,
    ).buildAnimatedWidget(context, controller!);

    if (mounted) {
      controller?.forward();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    animation = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animation!;
  }
}
