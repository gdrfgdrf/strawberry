
import 'package:flutter/cupertino.dart';

class DisposeDetector extends StatefulWidget {
  final Function onDispose;
  final Widget child;
  const DisposeDetector({super.key,
    required this.child,
    required this.onDispose,
  });
  @override
  _DisposeDetectorState createState() => _DisposeDetectorState();
}

class _DisposeDetectorState extends State<DisposeDetector> {
  @override
  void dispose() {
    super.dispose();
    widget.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}