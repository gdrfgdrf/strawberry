import 'package:flutter/cupertino.dart';

class MenuNode {
  final Widget? leading;
  final Widget? trailing;
  final Widget? content;

  ContextMenu? inner;

  MenuNode({this.leading, this.trailing, this.content, this.inner});
}

class ContextMenu {
  final Widget? title;
  final List<MenuNode> nodes = const [];

  const ContextMenu({this.title});
}

class RawContextMenuBuilder {
  ContextMenu? _menu;
  MenuNode? _node;

  RawContextMenuBuilder menu({Widget? title}) {
    _menu = ContextMenu();
    _node = null;

    return this;
  }

  RawContextMenuBuilder node({
    Widget? leading,
    Widget? trailing,
    Widget? content,
  }) {
    if (_menu != null && _node != null) {
      _menu!.nodes.add(_node!);
    }

    _node = MenuNode(leading: leading, trailing: trailing, content: content);

    return this;
  }

  RawContextMenuBuilder combine(RawContextMenuBuilder another) {
    _node?.inner = another.finish();
    return this;
  }

  ContextMenu? finish() {
    if (_menu != null && _node != null) {
      _menu?.nodes.add(_node!);
    }
    return _menu;
  }
}
