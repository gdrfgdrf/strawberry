import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:widgets/animation/smooth_fade_animation.dart';
import 'package:widgets/animation/smooth_overflow_widget_animation.dart';

import 'animation_combine.dart';

class OverflowWidgetWrapper extends StatefulWidget {
  const OverflowWidgetWrapper._internal({
    super.key,
    required this.child,
    this.minWidth,
    this.minHeight,
    required this.maxWidth,
    required this.maxHeight,
    this.padding,
  });

  static OverflowWidgetWrapper create({
    required Widget child,
    double? minWidth,
    double? minHeight,
    required double maxWidth,
    required double maxHeight,
    EdgeInsets? padding,
  }) {
    final key = GlobalKey();

    return OverflowWidgetWrapper._internal(
      key: key,
      minWidth: minWidth,
      minHeight: minHeight,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      padding: padding,
      child: child,
    );
  }

  final Widget child;
  final double? minWidth;
  final double? minHeight;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets? padding;

  @override
  State<StatefulWidget> createState() => _OverflowWidgetWrapper();
}

class _OverflowWidgetWrapper extends State<OverflowWidgetWrapper> {

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();

    final overflowAnimation = SmoothOverflowWidgetAnimation(
      parentKey: widget.key as GlobalKey,
      childKey: key,
      chunkSize: 36,
      axis: Axis.horizontal,
      eachDuration: Duration(milliseconds: 500),
      child: widget.child,
    );

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight,
          fit: OverflowBoxFit.deferToChild,
          child: SizedBox(key: key, child: overflowAnimation),
        ),
      ),
    );
  }
}
