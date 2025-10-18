import 'package:flutter/cupertino.dart';

import 'animated_overlay_entry.dart';

class PositionCalculateResult {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  const PositionCalculateResult({this.top, this.left, this.right, this.bottom});

  bool isEmpty() {
    final actualTop = top ?? 0;
    final actualLeft = left ?? 0;
    final actualRight = right ?? 0;
    final actualBottom = bottom ?? 0;
    if (actualTop == 0 &&
        actualLeft == 0 &&
        actualRight == 0 &&
        actualBottom == 0) {
      return true;
    }
    return false;
  }

  static PositionCalculateResult empty = PositionCalculateResult(
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  );
}

class OverlayCalculation {
  static PositionCalculateResult calculatePosition(
    GlobalKey parentKey,
    double width,
    double height, {
    double? infix,
    PositionDirection? positionDirection,
  }) {
    final renderBox =
        parentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return PositionCalculateResult.empty;
    }

    final globalOffset = renderBox.localToGlobal(Offset.zero);
    final parentSize = renderBox.size;

    final actualInfix = infix ?? 0;
    final actualPositionDirection =
        positionDirection ?? PositionDirection.downRight;
    Offset? calculatedOffset;

    if (actualPositionDirection == PositionDirection.upLeft) {
      calculatedOffset = Offset(
        globalOffset.dx - (width - parentSize.width),
        globalOffset.dy - parentSize.height - actualInfix,
      );
    }
    if (actualPositionDirection == PositionDirection.upRight) {
      calculatedOffset = Offset(
        globalOffset.dx,
        globalOffset.dy - parentSize.height - actualInfix,
      );
    }
    if (actualPositionDirection == PositionDirection.downLeft) {
      calculatedOffset = Offset(
        globalOffset.dx - (width - parentSize.width),
        globalOffset.dy + parentSize.height + actualInfix,
      );
    }
    if (actualPositionDirection == PositionDirection.downRight) {
      calculatedOffset = Offset(
        globalOffset.dx,
        globalOffset.dy + parentSize.height + actualInfix,
      );
    }
    if (actualPositionDirection == PositionDirection.leftUp) {
      calculatedOffset = Offset(
        globalOffset.dx - parentSize.width - actualInfix,
        globalOffset.dy,
      );
    }
    if (actualPositionDirection == PositionDirection.leftDown) {
      calculatedOffset = Offset(
        globalOffset.dx - parentSize.width - actualInfix,
        globalOffset.dy - (height - parentSize.height),
      );
    }
    if (actualPositionDirection == PositionDirection.rightUp) {
      calculatedOffset = Offset(
        globalOffset.dx + parentSize.width + actualInfix,
        globalOffset.dy,
      );
    }
    if (actualPositionDirection == PositionDirection.rightDown) {
      calculatedOffset = Offset(
        globalOffset.dx + parentSize.width + actualInfix,
        globalOffset.dy - (height - parentSize.height),
      );
    }

    return PositionCalculateResult(
      left: calculatedOffset!.dx,
      top: calculatedOffset.dy,
    );
  }
}
