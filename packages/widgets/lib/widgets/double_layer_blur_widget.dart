import 'package:flutter/material.dart';
import 'package:widgets/animation/animation_bean.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_opacity_animation.dart';

class DoubleLayerBlurWidget extends StatefulWidget {
  final Widget down;
  final Widget up;

  final double blur;
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final double blurRadius;

  final ValueNotifier<bool>? stateNotifier;
  final ValueNotifier<Widget>? upNotifier;

  const DoubleLayerBlurWidget({
    super.key,
    required this.down,
    required this.up,
    this.blur = 10.0,
    required this.width,
    required this.height,
    this.borderRadius,
    this.blurRadius = 20.0,
    this.stateNotifier,
    this.upNotifier,
  });

  @override
  State<StatefulWidget> createState() => DoubleLayerBlurWidgetState();
}

class DoubleLayerBlurWidgetState extends State<DoubleLayerBlurWidget> {
  bool? previousState;
  bool? currentState;
  ValueNotifier<bool>? stateNotifier;
  ValueNotifier<Widget>? upNotifier;

  @override
  void initState() {
    super.initState();
    stateNotifier = widget.stateNotifier ?? ValueNotifier(false);
    upNotifier = widget.upNotifier ?? ValueNotifier(widget.up);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: stateNotifier!,
      builder: (_, state, _) {
        previousState = currentState;

        final animation = SmoothOpacityAnimation(
          key: UniqueKey(),
          opacityTarget: OpacityTarget(0.0, 1.0),
          blurTarget: BlurTarget(0.0, 5.0),
          width: widget.width,
          height: widget.height,
          borderRadius: BorderRadius.circular(20),
          duration: Duration(milliseconds: 500),
          child: ValueListenableBuilder(
            valueListenable: upNotifier!,
            builder: (_, widget, _) {
              return Center(child: widget,);
            },
          ),
        );

        AnimationCombination.newBuilder()
            .add(animation)
            .build(
              onReady: (animation) {
                if (previousState == state) {
                  return;
                }

                currentState = state;
                if (state) {
                  animation.forwardAll();
                } else {
                  animation.reverseAll();
                }
              },
            );

        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              width: widget.width,
              height: widget.height,
              child: widget.down,
            ),

            Center(child: animation),
          ],
        );
      },
    );
  }
}
