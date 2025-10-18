import 'package:flutter/cupertino.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_widget_switch_animation.dart';

class SmoothStreamBuilder<T> extends StatefulWidget {
  final Stream<T> stream;
  final AsyncWidgetBuilder builder;
  final AlignmentDirectional alignment;

  const SmoothStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.alignment = AlignmentDirectional.center
  });

  @override
  State<StatefulWidget> createState() => _SmoothStreamBuilderState<T>();
}

class _SmoothStreamBuilderState<T> extends State<SmoothStreamBuilder<T>> {
  T? previous;
  T? current;

  @override
  void dispose() {
    previous = null;
    current = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stream,
      builder: (context, data) {
        previous = current;
        current = data.data;

        final currentWidget = widget.builder(
          context,
          AsyncSnapshot.withData(data.connectionState, current),
        );

        if (previous == current) {
          return currentWidget;
        }

        final previousWidget = widget.builder(
          context,
          AsyncSnapshot.withData(ConnectionState.done, previous),
        );

        final animation = SmoothWidgetSwitchAnimation(
          key: UniqueKey(),
          before: previousWidget,
          after: currentWidget,
          alignment: widget.alignment,
          duration: Duration(milliseconds: 500),
        );

        AnimationCombination.newBuilder()
            .add(animation)
            .build(
              onReady: (animation) {
                animation.forwardAll();
              },
            );

        return animation;
      },
    );
  }
}
