import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:shared/string_extension.dart';
import 'package:widgets/dialog/text_dialog.dart';
import 'package:widgets/widgets/animated_hover_widget.dart';

class CopyableText extends StatelessWidget {
  final String text;

  const CopyableText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isBlank()) {
      return SizedBox.shrink();
    }

    return AnimatedHoverWidget(
      borderRadius: BorderRadius.circular(16),
      main:
          Text(text).applyConstraint(left: parent.left, top: parent.top)
              as Constrained,
      children: [
        FloatingActionButton(
              onPressed: () {
                TextDialog.show(context, text);
              },
              mini: true,
              child: Icon(Icons.zoom_out_map_rounded),
            ).applyConstraint(right: parent.right, bottom: parent.bottom)
            as Constrained,
      ],
    );
  }
}
