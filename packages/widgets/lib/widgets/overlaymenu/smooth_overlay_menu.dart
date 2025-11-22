import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:widgets/animation/animation_bean.dart';
import 'package:widgets/widgets/listview/animated_list_item.dart';
import 'package:widgets/widgets/overlay/animated_overlay_entry.dart';

class OverlayMenuEntry {
  Widget? leadingIcon;
  Widget? trailingIcon;
  Widget? content;
  VoidCallback? onClicked;

  OverlayMenuEntry({
    this.leadingIcon,
    this.trailingIcon,
    this.content,
    this.onClicked,
  });
}

class SmoothOverlayMenu {
  final GlobalKey parentKey;
  final PositionDirection? positionDirection;

  final Widget? top;
  final Widget? bottom;
  final List<OverlayMenuEntry> children;

  final Widget? topDivider;
  final Widget? bottomDivider;

  final VoidCallback? onHover;
  final VoidCallback? onExit;

  final List<Widget> _builtChildren = [];
  AnimatedOverlayEntry? _overlayEntry;
  bool shown = false;

  SmoothOverlayMenu({
    required this.parentKey,
    this.positionDirection,
    this.top,
    this.bottom,
    required this.children,
    this.topDivider,
    this.bottomDivider,
    this.onHover,
    this.onExit,
  });

  Widget buildEnd(Widget? widget, {Widget? divider, bool isBottom = false}) {
    if (widget == null) {
      return SizedBox.shrink();
    }

    final dividerId = ConstraintId("divider");
    final dividerWidget = (divider ?? Divider()).applyConstraint(
      id: dividerId,
      left: parent.left,
      right: parent.right,
      top: isBottom ? parent.top : null,
      bottom: isBottom ? null : parent.bottom,
    );

    return SmoothContainer(
      width: 200.w,
      height: 55.h,
      borderRadius: BorderRadius.only(
        topLeft: isBottom ? Radius.zero : Radius.circular(16),
        topRight: isBottom ? Radius.zero : Radius.circular(16),
        bottomLeft: isBottom ? Radius.circular(16) : Radius.zero,
        bottomRight: isBottom ? Radius.circular(16) : Radius.zero
      ),
      color: themeData().colorScheme.surfaceContainerLow,
      child: ConstraintLayout(
        children: [
          widget.applyConstraint(
            left: parent.left,
            right: parent.right,
            top: parent.top,
            bottom: parent.bottom,
          ),

          dividerWidget,
        ],
      ),
    );
  }

  Widget buildChild(
    OverlayMenuEntry entry, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final leadingIcon = entry.leadingIcon;
    final content = entry.content;
    final trailingIcon = entry.trailingIcon;

    final leadingIconId = ConstraintId("leading-icon");
    final contentId = ConstraintId("content");

    final borderRadius = BorderRadius.only(
      topLeft: (isFirst && top == null) ? Radius.circular(12) : Radius.zero,
      topRight: (isFirst && top == null) ? Radius.circular(12) : Radius.zero,
      bottomLeft: (isLast && bottom == null) ? Radius.circular(12) : Radius.zero,
      bottomRight: (isLast && bottom == null) ? Radius.circular(12) : Radius.zero,
    );

    return AnimatedListItem(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: entry.onClicked,
          child: SmoothContainer(
            width: 200.w,
            height: 43.h,
            borderRadius: borderRadius,
            child: Padding(
              padding: EdgeInsets.only(left: 14.w, right: 9.w),
              child: ConstraintLayout(
                children: [
                  SmoothContainer(
                    width: 24.w,
                    height: 24.w,
                    alignment: Alignment.centerLeft,
                    child: leadingIcon,
                  ).applyConstraint(
                    id: leadingIconId,
                    left: parent.left,
                    top: parent.top,
                    bottom: parent.bottom,
                  ),

                  SmoothContainer(
                    width: 110.w,
                    height: 43.h,
                    alignment:
                    trailingIcon != null
                        ? Alignment.centerLeft
                        : Alignment.center,
                    child: content,
                  ).applyConstraint(
                    id: contentId,
                    left: leadingIconId.right,
                    top: parent.top,
                    bottom: parent.bottom,
                    margin: EdgeInsets.only(left: 12.w),
                  ),

                  (trailingIcon ?? SizedBox.shrink()).applyConstraint(
                    left: contentId.right,
                    top: parent.top,
                    bottom: parent.bottom,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListView() {
    _builtChildren.clear();

    for (int i = 0; i < children.length; i++) {
      final entry = children[i];
      final isFirst = i == 0;
      final isLast = i == children.length - 1;

      final item = buildChild(entry, isFirst: isFirst, isLast: isLast);
      _builtChildren.add(item);
    }
    double height;
    if (top != null && bottom != null) {
      height = 219.h;
    } else {
      if (top != null || bottom != null) {
        height = 274.h;
      } else {
        height = 329.h;
      }
    }

    return SmoothContainer(
      width: 200.w,
      height: height,
      child: SmoothListView(
        duration: Duration(milliseconds: 500),
        physics: BouncingScrollPhysics(),
        children: _builtChildren,
      ),
    );
  }

  Widget combine() {
    final topId = ConstraintId("top");

    return SmoothContainer(
      width: 200.w,
      height: 329.h,
      borderRadius: BorderRadius.circular(16),
      color: themeData().colorScheme.surfaceContainerLow,
      child: ConstraintLayout(
        children: [
          buildEnd(top, divider: topDivider).applyConstraint(
            id: topId,
            left: parent.left,
            right: parent.right,
            top: parent.top,
          ),
          buildListView().applyConstraint(
            left: parent.left,
            right: parent.right,
            top: topId.bottom,
          ),
          buildEnd(bottom, divider: bottomDivider, isBottom: true).applyConstraint(
            left: parent.left,
            right: parent.right,
            bottom: parent.bottom,
          ),
        ],
      ),
    );
  }

  void show(BuildContext context) {
    if (_overlayEntry != null && _overlayEntry!.shown) {
      hide();
    }

    _overlayEntry = AnimatedOverlayEntry(
      parentKey: parentKey,
      positionDirection: positionDirection,
      direction: AnimationDirection.verticalTopToBottom,
      width: 200.w,
      height: 329.h,
      child: MouseRegion(
        onEnter: (_) {
          onHover?.call();
        },
        onExit: (_) {
          onExit?.call();
        },
        child: combine(),
      ),
    );
    _overlayEntry?.show(context);
    shown = true;
  }

  void hide() {
    _overlayEntry?.hide();
    _overlayEntry = null;
    shown = false;
  }

  void toggle(BuildContext context) {
    if (shown) {
      hide();
    } else {
      show(context);
    }
  }
}
