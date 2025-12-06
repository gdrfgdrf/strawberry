import 'dart:async';
import 'dart:io';

import 'package:find_size/find_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared/lyric/lyric_parser.dart';

import '../animated_blur.dart';
import 'next_lyrics_calculator.dart';

class AnimatedPositionedLyric extends StatefulWidget {
  final double? width;
  final void Function(Size)? onSizeCompleted;
  final VoidCallback? onClicked;

  final Stream<CalculatedLyrics?> calculateStream;

  final int index;
  final int total;
  final CombinedLyric lyric;

  final ColorScheme? colorScheme;

  const AnimatedPositionedLyric({
    super.key,
    this.width,
    this.onSizeCompleted,
    this.onClicked,
    required this.calculateStream,
    required this.index,
    required this.total,
    required this.lyric,
    required this.colorScheme,
  });

  @override
  State<StatefulWidget> createState() => _AnimatedPositionedLyricState();
}

class _AnimatedPositionedLyricState extends State<AnimatedPositionedLyric>
    with WidgetsBindingObserver {
  final List<StreamSubscription> subscriptions = [];
  int? centerIndex;
  CalculatedLyric? calculatedLyric;
  Widget? cachedWidget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final calculateSubscription = widget.calculateStream.listen((
      calculatedLyrics,
    ) {
      if (calculatedLyrics == null) {
        return;
      }

      centerIndex = calculatedLyrics.centerIndex;
      calculatedLyric = calculatedLyrics.calculatedLyrics[widget.index];
      if (calculatedLyric == null) {
        return;
      }

      setState(() {});
    });
    subscriptions.add(calculateSubscription);

    cachedWidget = buildCenterLyric();
  }

  String? getFont() {
    if (!Platform.isWindows) {
      return null;
    }
    return "Microsoft YaHei";
  }

  List<String>? getFallbackFonts() {
    if (!Platform.isWindows) {
      return null;
    }
    return ["Arial"];
  }

  Widget buildCenterLyric() {
    final lyric = widget.lyric.text;
    final translatedLyric = widget.lyric.translatedText;
    final romanLyric = widget.lyric.romanText;

    Widget translatedLyricText = const SizedBox.shrink();
    Widget romanLyricText = const SizedBox.shrink();
    if (translatedLyric != null) {
      translatedLyricText = Text(
        translatedLyric,
        softWrap: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24.sp,
          fontFamily: getFont(),
          fontFamilyFallback: getFallbackFonts(),
          shadows: [Shadow(blurRadius: 6)],
          color: widget.colorScheme?.secondaryContainer.withAlpha(160),
        ),
      );
    }
    if (romanLyric != null) {
      romanLyricText = Text(
        romanLyric,
        softWrap: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20.sp,
          fontFamily: getFont(),
          fontFamilyFallback: getFallbackFonts(),
          shadows: [Shadow(blurRadius: 6)],
          color: widget.colorScheme?.secondaryContainer.withAlpha(160),
        ),
      );
    }
    final lyricId = ConstraintId("lyric");
    final romanId = ConstraintId("roman");
    final translatedId = ConstraintId("translated");

    return FindSize(
      onChange: (size) {
        widget.onSizeCompleted?.call(size);
      },
      child: ConstraintLayout(
        width: widget.width ?? 240,
        height: wrapContent,
        children: [
          Text(
            lyric ?? "",
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32.sp,
              fontFamily: getFont(),
              fontFamilyFallback: getFallbackFonts(),
              shadows: [Shadow(blurRadius: 12)],
              fontWeight: FontWeight.bold,
              color: widget.colorScheme?.secondaryContainer,
            ),
          ).applyConstraint(
            id: lyricId,
            top: parent.top,
            left: parent.left,
            right: parent.right,
            width: widget.width ?? 240,
          ),
          romanLyricText.applyConstraint(
            id: romanId,
            top: lyricId.bottom,
            left: parent.left,
            right: parent.right,
            width: widget.width ?? 240,
          ),
          translatedLyricText.applyConstraint(
            id: translatedId,
            top: romanId.bottom,
            left: parent.left,
            right: parent.right,
            width: widget.width ?? 240,
          ),
          SizedBox().applyConstraint(
            top: translatedId.bottom,
            left: parent.left,
            right: parent.right,
            height: 24.h,
          ),
        ],
      ),
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    cachedWidget = buildCenterLyric();
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
    calculatedLyric = null;
    super.dispose();
  }

  double calculateOpacity() {
    final distance = (widget.index - (centerIndex ?? 0)).abs();
    double k1 = 1 / distance;
    if (distance == 0) {
      k1 = 1;
    }
    if (distance == 1) {
      k1 = 0.6;
    }
    return k1;
  }

  Duration? correctDuration(Duration? provided) {
    if (provided == null) {
      return null;
    }
    if (provided < Duration.zero) {
      return Duration(milliseconds: 50);
    }
    return provided;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: calculatedLyric?.offset.dy,
      curve: Curves.fastEaseInToSlowEaseOut,
      width: widget.width ?? 240,
      duration:
          correctDuration(calculatedLyric?.duration) ??
          const Duration(milliseconds: 500),
      child: RepaintBoundary(
        child:
            calculatedLyric == null
                ? cachedWidget!
                : calculatedLyric!.visible
                ? AnimatedOpacity(
                  opacity: calculateOpacity(),
                  duration: Duration(milliseconds: 250),
                  child: AnimatedBlur(
                    value:
                        (widget.index - (centerIndex ?? 0)).abs() == 0
                            ? 0.0
                            : 2.0,
                    duration: Duration(milliseconds: 250),
                    child: GestureDetector(
                      onTap: () {
                        widget.onClicked?.call();
                      },
                      child: cachedWidget,
                    ),
                  ),
                )
                : SizedBox.shrink(),
      ),
    );
  }
}
