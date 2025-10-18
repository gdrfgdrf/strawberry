import 'package:flutter/material.dart';
import 'package:widgets/widgets/listview/animated_list_item.dart';

import 'smooth_overlay_menu.dart';

class OverlayMenuItem extends StatelessWidget {
  final OverlayMenuEntry entry;

  const OverlayMenuItem({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return AnimatedListItem(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          entry.onClicked?.call();
        },
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              entry.leadingIcon ?? SizedBox.shrink(),

              entry.content ?? SizedBox.shrink(),

              entry.trailingIcon ?? SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
