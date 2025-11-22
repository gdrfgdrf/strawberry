import 'dart:async';

import 'package:find_size/find_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared/platform_extension.dart';
import 'package:widgets/widgets/overlaymenu/smooth_overlay_menu.dart';

import '../overlay/animated_overlay_entry.dart';

class OverlayMenuController {
  void Function(BuildContext?, bool)? onSwitch;

  void show(BuildContext context) {
    onSwitch?.call(context, true);
  }

  void hide() {
    onSwitch?.call(null, false);
  }

  void setOnSwitch(void Function(BuildContext?, bool) onSwitch) {
    this.onSwitch = onSwitch;
  }
}

class AutoOverlayMenu extends StatelessWidget {
  final Widget child;

  final PositionDirection? positionDirection;

  final Widget? top;
  final Widget? bottom;
  final List<OverlayMenuEntry> children;

  final Widget? topDivider;
  final Widget? bottomDivider;

  final VoidCallback? onHover;
  final VoidCallback? onExit;

  GlobalKey? parentKey = GlobalKey();
  OverlayMenuController? controller;

  SmoothOverlayMenu? smoothOverlayMenu;
  bool? overlayHovered;
  bool? childHovered;

  AutoOverlayMenu({
    super.key,
    required this.child,
    this.parentKey,
    this.positionDirection,
    this.top,
    this.bottom,
    required this.children,
    this.topDivider,
    this.bottomDivider,
    this.onHover,
    this.onExit,
    this.controller,
  }) {
    parentKey ??= GlobalKey();
  }

  void hide() {
    smoothOverlayMenu?.hide();
  }

  void updateOverlayHovered(bool target) {
    overlayHovered = target;
    checkHoverStatus();
  }

  void updateChildHovered(BuildContext context, bool target) {
    childHovered = target;

    if (smoothOverlayMenu?.shown == false) {
      smoothOverlayMenu?.show(context);
    }

    checkHoverStatus();
  }

  void checkHoverStatus() {
    if (overlayHovered == false && childHovered == false) {
      Timer(Duration(milliseconds: 100), () {
        if (overlayHovered == false && childHovered == false) {
          smoothOverlayMenu?.hide();
        }
      });
    }
  }

  void onSized(Size size) {
    smoothOverlayMenu = SmoothOverlayMenu(
      parentKey: parentKey!,
      positionDirection: positionDirection,
      top: top,
      bottom: bottom,
      children: children,
      topDivider: topDivider,
      bottomDivider: bottomDivider,
      onHover: () {
        onHover?.call();
        updateOverlayHovered(true);
      },
      onExit: () {
        onExit?.call();
        updateOverlayHovered(false);
      },
    );

    controller?.setOnSwitch((context, flag) {
      if (flag) {
        smoothOverlayMenu?.show(context!);
        return;
      }
      hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformExtension.isDesktop) {
      return FindSize(
        key: parentKey,
        onChange: onSized,
        child: MouseRegion(
          onEnter: (_) {
            updateChildHovered(context, true);
          },
          onExit: (_) {
            updateChildHovered(context, false);
          },
          child: child,
        ),
      );
    }

    return FindSize(
      key: parentKey,
      onChange: onSized,
      child: GestureDetector(
        onTap: () {
          smoothOverlayMenu?.toggle(context);
        },
        child: child,
      ),
    );
  }
}
