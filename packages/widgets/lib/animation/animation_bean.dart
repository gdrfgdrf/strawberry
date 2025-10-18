import 'package:flutter/cupertino.dart';
import 'package:widgets/animation/animation_combine.dart';

enum AnimationDirection {
  verticalTopToBottom,
  verticalBottomToTop,
  horizontalLeftToRight,
  horizontalRightToLeft,
}

class OpacityTarget {
  final double before;
  final double after;

  const OpacityTarget(this.before, this.after);
}

class BlurTarget {
  final double before;
  final double after;

  const BlurTarget(this.before, this.after);
}

class ScaleRatio {
  final double before;
  final double after;

  const ScaleRatio(this.before, this.after);
}

class PositionTarget {
  final double horizontalFactor;
  final double verticalFactor;
  final Alignment alignment;

  const PositionTarget(this.horizontalFactor, this.verticalFactor, {this.alignment = Alignment.center});
}