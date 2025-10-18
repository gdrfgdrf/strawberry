import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgets/floatingtoast/floating_text_toast.dart';

class TextDialog {
  static void show(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Text Dialog"),
          content: SelectableText(text),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                if (context.mounted) {
                  FloatingTextToast.show(context, "Text Copied");
                }
              },
              child: Text("Copy"),
            ),
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: Text("Close")),
          ],
        );
      },
    );
  }
}
