import 'package:flutter/widgets.dart';

abstract class ControllableAnimatedWidget extends StatefulWidget {
  void Function(AnimationController)? onControllerCreated;

  ControllableAnimatedWidget({super.key});

  @protected
  AnimationController createController(TickerProvider vsync);

  @protected
  Widget buildAnimatedWidget(
    BuildContext context,
    AnimationController controller,
  );

  @override
  State<StatefulWidget> createState() => _ControllableAnimatedWidgetState();
}

class _ControllableAnimatedWidgetState extends State<ControllableAnimatedWidget>
    with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.createController(this);
    widget.onControllerCreated?.call(_controller!);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      throw ArgumentError("controller is not initialized");
    }
    return widget.buildAnimatedWidget(context, _controller!);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
