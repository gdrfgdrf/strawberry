import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_widget_switch_animation.dart';
import 'package:widgets/widgets/animated_linear_progress_indicator.dart';

class SmoothLinearProgressIndicator extends StatefulWidget {
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

  const SmoothLinearProgressIndicator({
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
  State<StatefulWidget> createState() => _SmoothLinearProgressIndicatorState();
}

class _SmoothLinearProgressIndicatorState
    extends State<SmoothLinearProgressIndicator> {
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
    final actualProgressWidth = widget.progressWidth ?? 480.w;
    final actualProgressHeight = widget.progressHeight ?? 4;
    final actualDurationWidth = widget.durationWidth ?? 48.w;
    final actualDurationHeight = widget.durationHeight ?? 16;

    return SizedBox(
      width: actualProgressWidth + actualDurationWidth * 2,
      height: max(actualProgressHeight, actualDurationHeight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SmoothContainer(
            height: actualDurationHeight,
            child: Material(
              color: Colors.transparent,
              child: ValueListenableBuilder(
                valueListenable: innerTotalDurationNotifier,
                builder: (context, totalDuration, _) {
                  String previousString = "Nothing";
                  if (previousTotalDuration != null) {
                    previousString = "0:00:00";
                  }

                  String totalString = "Nothing";
                  if (totalDuration != null) {
                    totalString = "0:00:00";
                  }

                  final animation = SmoothWidgetSwitchAnimation(
                    before: Text(
                      previousString,
                      style: TextStyle(fontSize: 10.sp),
                    ),
                    after: Text(totalString, style: TextStyle(fontSize: 10.sp)),
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
              ),
            ),
          ),

          GestureDetector(
            onTapUp: (details) {
              if (totalDuration == null) {
                return;
              }

              final position = details.localPosition;
              final dx = position.dx;
              final target = dx / actualProgressWidth;
              final clickDuration = Duration(
                milliseconds: (totalDuration!.inMilliseconds * target).toInt(),
              );
              widget.onClick?.call(clickDuration);
            },
            child: SizedBox(
              width: actualProgressWidth,
              height: actualProgressHeight,
              child: SmoothClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AnimatedLinearProgressIndicator(
                  valueNotifier: progressNotifier,
                ),
              ),
            ),
          ),

          SmoothContainer(
            height: actualDurationHeight,
            child: Material(
              color: Colors.transparent,
              child: ValueListenableBuilder(
                valueListenable: innerTotalDurationNotifier,
                builder: (context, totalDuration, _) {
                  String previousString = "Nothing";
                  if (previousTotalDuration != null) {
                    previousString = previousTotalDuration!.toString();
                    if (previousString.contains(".")) {
                      previousString = previousString.substring(
                        0,
                        previousString.indexOf("."),
                      );
                    }
                  }

                  String totalString = "Nothing";
                  if (totalDuration != null) {
                    totalString = totalDuration.toString();
                    if (totalString.contains(".")) {
                      totalString = totalString.substring(
                        0,
                        totalString.indexOf("."),
                      );
                    }
                  }

                  final animation = SmoothWidgetSwitchAnimation(
                    key: UniqueKey(),
                    before: Text(
                      previousString,
                      style: TextStyle(fontSize: 10.sp),
                    ),
                    after: Text(totalString, style: TextStyle(fontSize: 10.sp)),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
