import 'dart:async';
import 'dart:io';

import 'package:find_size/find_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:widgets/widgets/animated_blur.dart';
import 'package:widgets/widgets/nextlyrics/next_lyrics.dart';

class NextSmoothLyrics extends StatefulWidget {
  final double? width;
  final double? height;
  final double? gap;

  final double? lyricWidth;

  final List<CombinedLyric> lyrics;
  final Stream<int?> indexStream;

  final ColorScheme? colorScheme;

  final void Function(int)? onLyricClicked;

  const NextSmoothLyrics({
    super.key,
    this.width,
    this.height,
    this.gap,
    this.lyricWidth,
    required this.lyrics,
    required this.indexStream,
    this.colorScheme,
    this.onLyricClicked,
  });

  @override
  State<StatefulWidget> createState() => _NextSmoothLyricsState();
}

class _NextSmoothLyricsState extends State<NextSmoothLyrics> {
  bool allSizeCompleted = false;
  List<RenderedLyric> renderedLyrics = [];
  BehaviorSubject<CalculatedLyrics?> calculateStream = BehaviorSubject.seeded(
    null,
  );
  StreamSubscription? indexSubscription;

  void onAllSizeCompleted() {
    renderedLyrics.sort((a, b) => a.index.compareTo(b.index));

    final screenSize = MediaQuery.of(context).size;
    indexSubscription = widget.indexStream.listen((index) {
      if (index == null) {
        return;
      }

      final calculatedLyrics = LyricCalculator.offsets(
        renderedLyrics,
        index,
        widget.height ?? screenSize.height,
        0,
      );
      calculateStream.add(calculatedLyrics);
    });
  }

  void onSizeCompleted(int index, Size size) {
    if (allSizeCompleted) {
      return;
    }

    final renderedLyric = RenderedLyric(index, size, widget.lyrics[index]);
    renderedLyrics.add(renderedLyric);
    if (renderedLyrics.length >= widget.lyrics.length) {
      onAllSizeCompleted();
    }
  }

  @override
  void dispose() {
    renderedLyrics.clear();
    calculateStream.close();
    indexSubscription?.cancel();
    indexSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    allSizeCompleted = false;
    renderedLyrics.clear();
    indexSubscription?.cancel();
    indexSubscription = null;

    final widgets = <Widget>[];
    for (int i = 0; i < widget.lyrics.length; i++) {
      final lyric = widget.lyrics[i];

      widgets.add(
        AnimatedPositionedLyric(
          key: UniqueKey(),
          width: widget.lyricWidth,
          calculateStream: calculateStream,
          index: i,
          total: widget.lyrics.length,
          lyric: lyric,
          colorScheme: widget.colorScheme,
          onSizeCompleted: (size) {
            onSizeCompleted(i, size);
          },
          onClicked: () {
            widget.onLyricClicked?.call(i);
          },
        ),
      );
    }

    return SmoothContainer(
      width: widget.width,
      height: widget.height,
      child: Stack(alignment: Alignment.topCenter, children: [...widgets]),
    );
  }
}

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

class _AnimatedPositionedLyricState extends State<AnimatedPositionedLyric> {
  final List<StreamSubscription> subscriptions = [];
  int? centerIndex;
  CalculatedLyric? calculatedLyric;

  @override
  void initState() {
    super.initState();
    final calculateSubscription = widget.calculateStream.listen((
      calculatedLyrics,
    ) {
      if (calculatedLyrics == null) {
        return;
      }

      centerIndex = calculatedLyrics.centerIndex;
      calculatedLyric = calculatedLyrics.offsets[widget.index];
      if (calculatedLyric == null) {
        return;
      }

      setState(() {});
    });
    subscriptions.add(calculateSubscription);
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

    Widget translatedLyricText = SizedBox.shrink();
    Widget romanLyricText = SizedBox.shrink();
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
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
    calculatedLyric = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distance = (widget.index - (centerIndex ?? 0)).abs();
    double k1 = 1 / distance;
    if (distance == 0) {
      k1 = 1;
    }
    if (distance == 1) {
      k1 = 0.6;
    }

    Duration? duration = calculatedLyric?.duration;
    if (duration != null && duration < Duration.zero) {
      duration = Duration(milliseconds: 50);
    }

    return AnimatedPositioned(
      top: calculatedLyric?.offset.dy,
      curve: Curves.fastEaseInToSlowEaseOut,
      width: widget.width ?? 240,
      duration: duration ?? Duration(milliseconds: 500),
      child: AnimatedOpacity(
        opacity: k1,
        duration: Duration(milliseconds: 250),
        child: AnimatedBlur(
          value: distance == 0 ? 0.0 : 2.0,
          duration: Duration(milliseconds: 250),
          child: GestureDetector(
            onTap: () {
              widget.onClicked?.call();
            },
            child: buildCenterLyric(),
          ),
        ),
      ),
    );
  }
}
