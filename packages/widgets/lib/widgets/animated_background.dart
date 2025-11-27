import 'package:flutter/material.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Alignment? alignment;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.alignment,
    this.padding,
    this.borderRadius,
  });

  @override
  State<StatefulWidget> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: SmoothClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        child: AnimatedContainer(
          width: widget.width,
          height: widget.height,
          alignment: widget.alignment,
          duration: Duration(milliseconds: 200),
          padding: widget.padding,
          decoration: BoxDecoration(
            color:
                isHovered
                    ? themeData().colorScheme.surfaceContainer.withAlpha(160)
                    : Colors.transparent,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
