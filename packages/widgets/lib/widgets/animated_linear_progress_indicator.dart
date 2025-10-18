import 'package:flutter/material.dart';

class AnimatedLinearProgressIndicator extends StatefulWidget {
  final ValueNotifier<double> valueNotifier;
  final Duration animationDuration;
  final double? minHeight;

  const AnimatedLinearProgressIndicator({
    super.key,
    required this.valueNotifier,
    this.animationDuration = const Duration(milliseconds: 100),
    this.minHeight,
  });

  @override
  State<AnimatedLinearProgressIndicator> createState() =>
      _AnimatedLinearProgressIndicatorState();
}

class _AnimatedLinearProgressIndicatorState
    extends State<AnimatedLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.valueNotifier.value,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );

    widget.valueNotifier.addListener(_handleValueChange);
  }

  void _handleValueChange() {
    final double newValue = widget.valueNotifier.value;

    if (newValue != _animation!.value) {
      setState(() {
        _previousValue = _animation!.value;
        _animation = Tween<double>(
          begin: _previousValue,
          end: newValue,
        ).animate(_controller!);
      });

      _controller!.reset();
      _controller!.forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    widget.valueNotifier.removeListener(_handleValueChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _animation!.value,
          minHeight: widget.minHeight,
        );
      },
    );
  }
}
