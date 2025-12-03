import 'package:flutter/cupertino.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:shared/platform_extension.dart';
import 'package:widgets/widgets/contextmenu/context_menu_display.dart';

class ContextMenuWrapper extends StatefulWidget {
  final List<ContextMenuEntry> entries;
  final Widget child;

  const ContextMenuWrapper({
    super.key,
    required this.entries,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _ContextMenuWrapperState();
}

class _ContextMenuWrapperState extends State<ContextMenuWrapper> {
  ContextMenuDisplay? display;

  @override
  void dispose() {
    display?.hide();
    display = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    display?.hide();
    display = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      display = ContextMenuDisplay(context, widget.entries);
    });

    return GestureDetector(
      onSecondaryTapUp: (details) {
        display?.show(details.globalPosition);
      },
      onLongPressStart: (details) {
        if (PlatformExtension.isDesktop) {
          return;
        }
        display?.show(details.globalPosition);
      },
      child: widget.child,
    );
  }
}
