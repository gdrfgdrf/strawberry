import 'package:flutter/cupertino.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

class ContextMenuDisplay {
  final BuildContext context;
  final List<ContextMenuEntry> entries;
  ContextMenu? contextMenu;

  ContextMenuDisplay(this.context, this.entries);

  void hide() {
    if (contextMenu == null) {
      return;
    }
    Navigator.pop(context);
    contextMenu = null;
  }

  void show(Offset position) {
    if (contextMenu != null) {
      hide();
    }

    contextMenu = ContextMenu(entries: entries, position: position);
    contextMenu?.show(context).then((_) {
      contextMenu = null;
    });
  }
}
