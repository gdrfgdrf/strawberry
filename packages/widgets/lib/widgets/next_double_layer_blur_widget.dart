import 'package:flutter/cupertino.dart';
import 'package:widgets/widgets/animated_blur.dart';

class NextDoubleBlurWidget extends StatefulWidget {
  final Widget? bottom;
  final Widget? overlay;
  final double blur;

  const NextDoubleBlurWidget({
    super.key,
    this.bottom,
    this.overlay,
    required this.blur,
  });

  @override
  State<StatefulWidget> createState() => _NextDoubleBlurWidgetState();
}

class _NextDoubleBlurWidgetState extends State<NextDoubleBlurWidget> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: AnimatedBlur(
              value: widget.blur,
              duration: Duration(milliseconds: 500),
              child: widget.bottom,
            ),
          ),

          Center(
            child: AnimatedOpacity(
              opacity: widget.blur > 0 ? 1 : 0,
              duration: Duration(milliseconds: 500),
              child: widget.overlay,
            ),
          ),
        ],
      ),
    );
  }
}
