import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_widget_switch_animation.dart';
import 'package:widgets/widgets/smooth_stream_builder.dart';

class SmoothSlider extends StatefulWidget {
  /// 480.w
  final double? progressWidth;

  /// 4
  final double? progressHeight;

  /// 48.w
  final double? durationWidth;

  /// 16
  final double? durationHeight;

  final Stream<Duration?> totalDurationStream;
  final Stream<Duration?> currentDurationStream;

  final void Function(Duration?)? onClick;

  const SmoothSlider({
    super.key,
    this.progressWidth,
    this.progressHeight,
    this.durationWidth,
    this.durationHeight,
    required this.totalDurationStream,
    required this.currentDurationStream,
    this.onClick,
  });

  @override
  State<StatefulWidget> createState() => _SmoothSliderState();
}

class _SmoothSliderState extends State<SmoothSlider> {
  final List<StreamSubscription> subscriptions = [];
  final ValueNotifier<Duration?> innerTotalDurationNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<double> progressNotifier = ValueNotifier(0);
  Duration? previousTotalDuration;
  Duration? totalDuration;

  @override
  void initState() {
    super.initState();
    final totalDurationSubscription = widget.totalDurationStream.listen((
      duration,
    ) {
      progressNotifier.value = 0;
      innerTotalDurationNotifier.value = duration;
      previousTotalDuration = totalDuration;
      totalDuration = duration;
    });
    final currentDurationSubscription = widget.currentDurationStream.listen((
      duration,
    ) {
      if (duration == null || totalDuration == null) {
        progressNotifier.value = 0;
        return;
      }
      progressNotifier.value =
          duration.inMilliseconds / totalDuration!.inMilliseconds;
    });
    subscriptions.add(totalDurationSubscription);
    subscriptions.add(currentDurationSubscription);
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    innerTotalDurationNotifier.dispose();
    progressNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPositionId = ConstraintId("current-position");
    final sliderId = ConstraintId("slider");
    final endPositionId = ConstraintId("end-position");

    final actualProgressWidth = widget.progressWidth ?? 480.w;
    final actualProgressHeight = widget.progressHeight ?? 4;

    return ConstraintLayout(
      children: [
        Material(
          color: Colors.transparent,
          child: StreamBuilder(stream: widget.currentDurationStream, builder: (context, positionData) {
            String text = "Nothing";
            if (positionData.hasData) {
              text = positionData.data!.toString();
              text = text.substring(0, text.indexOf("."));
            }
            return Text(text, style: TextStyle(fontSize: 10.sp));
          }),
        ).applyConstraint(
          top: parent.top,
          bottom: parent.bottom,
          right: sliderId.left,
        ),

        Material(
          color: Colors.transparent,
          child: ValueListenableBuilder(
            valueListenable: progressNotifier,
            builder: (context, progress, _) {
              return Slider(
                value: progress,
                thumbColor: Colors.transparent,
                onChanged: (value) {
                  final clickDuration = Duration(
                    milliseconds:
                        (totalDuration!.inMilliseconds * value).toInt(),
                  );
                  widget.onClick?.call(clickDuration);
                },
              );
            },
          ),
        ).applyConstraint(
          id: sliderId,
          top: parent.top,
          bottom: parent.bottom,
          left: parent.left,
          right: parent.right,
          width: actualProgressWidth,
          height: actualProgressHeight,
        ),

        Material(
          color: Colors.transparent,
          child: SmoothStreamBuilder(stream: widget.totalDurationStream, builder: (context, positionData) {
            String text = "Nothing";
            if (positionData.hasData) {
              text = positionData.data!.toString();
              text = text.substring(0, text.indexOf("."));
            }
            return Text(text, style: TextStyle(fontSize: 10.sp));
          }),
        ).applyConstraint(
          top: parent.top,
          bottom: parent.bottom,
          left: sliderId.right,
        ),
      ],
    );
  }
}
