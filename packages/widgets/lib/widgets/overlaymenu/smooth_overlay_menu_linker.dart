import 'dart:async';

import 'package:flutter/material.dart';
import 'package:widgets/widgets/overlaymenu/smooth_overlay_menu.dart';

class SmoothOverlayMenuLinker {
  final SmoothOverlayMenu overlayMenu;
  final List<GlobalKey> linkedKeys;
  final Duration closeDelay;

  final Map<GlobalKey, bool> stateMap = {};
  bool menuState = false;

  SmoothOverlayMenuLinker({
    required this.overlayMenu,
    required this.linkedKeys,
    this.closeDelay = const Duration(milliseconds: 500),
  }) {
   for (final key in linkedKeys) {
     stateMap[key] = false;
   }
   overlayMenu.onHover = () {
     menuState = true;
     tryHide();
   };
   overlayMenu.onExit = () {
     menuState = false;
     tryHide();
   };
  }

  bool state(GlobalKey key) {
    if (!stateMap.containsKey(key)) {
      throw ArgumentError("unknown key: $key");
    }
    return stateMap[key]!;
  }


  void updateHoverState(GlobalKey key, bool hovered) {
    if (!stateMap.containsKey(key)) {
      throw ArgumentError("unknown key: $key");
    }
    stateMap[key] = hovered;
    tryHide();
  }

  bool allOut() {
    return stateMap.values.every((hovered) => !hovered);
  }

  void tryHide() {
    if (allOut()) {
      Timer(closeDelay, () {
        if (allOut() && !menuState) {
          overlayMenu.hide();
        }
      });
    }
  }
}