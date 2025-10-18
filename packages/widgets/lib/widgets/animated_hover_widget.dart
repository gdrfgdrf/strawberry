import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:shared/themes.dart';

class AnimatedHoverWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Alignment? alignment;
  final BorderRadius? borderRadius;

  final Constrained main;
  final List<Constrained>? children;
  final Duration duration;

  const AnimatedHoverWidget({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.alignment,
    this.borderRadius,
    required this.main,
    this.children,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  State<StatefulWidget> createState() => _AnimatedHoverWidget();
}

class _AnimatedHoverWidget extends State<AnimatedHoverWidget>
    with TickerProviderStateMixin {
  bool isHovered = false;
  AnimationController? controller;
  Animation<double>? animation;
  Animation<double>? childrenOpacityAnimation;
  Animation<double>? childrenScaleAnimation;

  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  void initAnimation() {
    controller = AnimationController(vsync: this, duration: widget.duration);
    animation = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: controller!, curve: Curves.fastEaseInToSlowEaseOut),
    );
    childrenOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller!, curve: Curves.linear),
    );
  }

  void onHover() {
    setState(() {
      isHovered = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller?.forward();
    });
  }

  void onExit() {
    setState(() {
      isHovered = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller?.reverse();
    });
  }

  List<Widget> wrapChildren() {
    List<Widget> result = [];
    for (Constrained constrained in widget.children ?? []) {
      final animation = Opacity(
        opacity: childrenOpacityAnimation!.value,
        child: constrained.child,
      ).apply(constraint: constrained.constraint);
      result.add(animation);
    }
    return result;
  }

  @override
  void didUpdateWidget(covariant AnimatedHoverWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    initAnimation();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(),
      onExit: (_) => onExit(),
      child: AnimatedContainer(
        width: widget.width,
        height: widget.height,
        alignment: widget.alignment,
        padding: widget.padding,
        decoration: BoxDecoration(
          color:
              isHovered
                  ? themeData().colorScheme.surfaceContainerLow
                  : Colors.transparent,
          borderRadius: widget.borderRadius,
        ),
        duration: widget.duration,
        child: AnimatedBuilder(
          animation: controller!,
          builder: (context, _) {
            return Transform.scale(
              scale: animation!.value,
              child: ConstraintLayout(
                children: [
                  widget.main,
                  if (widget.children != null)
                    ...wrapChildren(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
