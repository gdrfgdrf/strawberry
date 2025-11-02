import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:find_size/find_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:widgets/animation/smooth_overflow_widget_animation.dart';

enum LyricDisplay { aligned, center }

class LyricOffsetDeltas {
  final int index;
  final Offset begin;
  final List<Offset> deltas;

  const LyricOffsetDeltas(this.index, this.begin, this.deltas);
}

class _LyricSize {
  final int index;
  final Size size;

  const _LyricSize(this.index, this.size);
}

class ScrollableLyrics extends StatefulWidget {
  final double? width;
  final double? height;

  final List<CombinedLyric> lyrics;
  final Stream<int?> indexStream;

  final void Function(int)? onLyricClicked;
  final double? lyricWidth;
  final LyricDisplay? lyricDisplay;

  const ScrollableLyrics({
    super.key,
    this.width,
    this.height,
    required this.lyrics,
    required this.indexStream,
    this.onLyricClicked,
    this.lyricWidth,
    this.lyricDisplay,
  });

  @override
  State<StatefulWidget> createState() => _ScrollableLyricsState();
}

class _ScrollableLyricsState extends State<ScrollableLyrics> {
  final List<_LyricSize> _sizes = [];

  StreamSubscription? indexSubscription;
  BehaviorSubject<LyricOffsetDeltas?> offsetDeltasStream =
      BehaviorSubject.seeded(null);
  BehaviorSubject<LyricAnimationDuration?> lyricAnimationDurationStream =
      BehaviorSubject.seeded(null);

  int? previousIndex;
  bool allSizeCompleted = false;
  Duration singleAnimationDuration = Duration(milliseconds: 500);

  void resetLyricAnimationDurations() {
    for (int i = 0; i < widget.lyrics.length; i++) {
      lyricAnimationDurationStream.add(
        LyricAnimationDuration(i, singleAnimationDuration),
      );
    }
  }

  void updateLyricAnimationDurations(int index) {
    for (int i = 1; i < widget.lyrics.length + 1; i++) {
      final k = i / (index + 1);
      final extraDuration = Duration(milliseconds: (pow(70, k)).toInt());
      Duration target = singleAnimationDuration * k + extraDuration;
      if (target < Duration.zero) {
        target = singleAnimationDuration * k;
      }

      lyricAnimationDurationStream.add(LyricAnimationDuration(i - 1, target));
    }
  }

  @override
  void initState() {
    super.initState();
    indexSubscription = widget.indexStream.listen((index) {
      if (index == null) {
        resetLyricAnimationDurations();
        previousIndex = null;
        return;
      }
      if (previousIndex != null) {
        final delta = index - previousIndex!;
        if (delta.abs() != 1) {
          resetLyricAnimationDurations();
          previousIndex = index;
          return;
        }
      }
      updateLyricAnimationDurations(index);
      previousIndex = index;
    });
  }

  List<double> calculateInitialOffsets() {
    final results = <double>[];

    final screenSize = MediaQuery.of(context).size;
    for (int i = 0; i < _sizes.length; i++) {
      if (i <= 0) {
        results.add(screenSize.height / 2.6);
        continue;
      }

      double previousTotal = 0;
      for (int x = 0; x < i; x++) {
        previousTotal += _sizes[x].size.height;
      }
      if (previousTotal <= 0) {
        continue;
      }

      results.add(screenSize.height / 2.6 + previousTotal);
    }

    return results;
  }

  void onAllSizeCompleted() {
    allSizeCompleted = true;

    _sizes.sort((a, b) => a.index.compareTo(b.index));

    final initialOffsets = calculateInitialOffsets();

    for (int i = 0; i < _sizes.length; i++) {
      final deltas = <double>[];

      final height = _sizes[i].size.height;
      for (int x = 0; x < i; x++) {
        final previous = _sizes[x];
        deltas.add(-previous.size.height);
      }

      deltas.add(-height);

      for (int x = i + 1; x < _sizes.length; x++) {
        final forward = _sizes[x];
        deltas.add(-forward.size.height);
      }

      final wrapped = LyricOffsetDeltas(
        i,
        Offset(0, initialOffsets[i]),
        deltas.map((delta) => Offset(0, delta)).toList(),
      );
      offsetDeltasStream.add(wrapped);
    }
  }

  void onSizeCompleted(int index, Size size) {
    if (allSizeCompleted) {
      return;
    }

    _sizes.add(_LyricSize(index, size));
    if (_sizes.length >= widget.lyrics.length) {
      onAllSizeCompleted();
    }
  }

  @override
  void dispose() {
    _sizes.clear();
    offsetDeltasStream.close();
    lyricAnimationDurationStream.close();
    indexSubscription?.cancel();
    indexSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    allSizeCompleted = false;
    _sizes.clear();

    final mapped = <Widget>[];
    for (int i = 0; i < widget.lyrics.length; i++) {
      Constraint constraint;
      if (widget.lyricDisplay == null ||
          widget.lyricDisplay == LyricDisplay.aligned) {
        constraint = Constraint(left: parent.left, top: parent.top);
      } else {
        constraint = Constraint(
          top: parent.top,
          left: parent.left,
          right: parent.right,
        );
      }

      mapped.add(
        Lyric(
          key: UniqueKey(),
          offsetStream: offsetDeltasStream.stream,
          indexStream: widget.indexStream,
          durationStream: lyricAnimationDurationStream.stream,
          index: i,
          total: widget.lyrics.length,
          lyric: widget.lyrics[i],
          width: widget.lyricWidth,
          display: widget.lyricDisplay,
          onSizeCompleted: (size) {
            onSizeCompleted(i, size);
          },
          onClicked: () {
            widget.onLyricClicked?.call(i);
          },
        ).apply(constraint: constraint),
      );
    }

    return SmoothContainer(
      width: widget.width,
      height: widget.height,
      child: ConstraintLayout(children: [...mapped]),
    );
  }
}

class _AnimationPart {
  final Animation<double> animation;
  final AnimationController controller;

  const _AnimationPart(this.animation, this.controller);
}

class LyricAnimationDuration {
  final int index;
  final Duration duration;

  const LyricAnimationDuration(this.index, this.duration);
}

class LyricOpacityAnimation {
  final int index;
  final double target;

  const LyricOpacityAnimation(this.index, this.target);
}

class Lyric extends StatefulWidget {
  final void Function(Size)? onSizeCompleted;
  final VoidCallback? onClicked;

  final Stream<LyricOffsetDeltas?> offsetStream;
  final Stream<int?> indexStream;
  final Stream<LyricAnimationDuration?> durationStream;

  final int index;
  final int total;
  final CombinedLyric lyric;

  final double? width;

  final LyricDisplay? display;

  const Lyric({
    super.key,
    this.onSizeCompleted,
    this.onClicked,
    required this.offsetStream,
    required this.indexStream,
    required this.durationStream,
    required this.index,
    required this.total,
    required this.lyric,
    this.width,
    this.display,
  });

  @override
  State<StatefulWidget> createState() => _LyricState();
}

class _LyricState extends State<Lyric> with TickerProviderStateMixin {
  final GlobalKey key = GlobalKey();

  StreamSubscription? offsetSubscription;
  StreamSubscription? indexSubscription;
  StreamSubscription? durationSubscription;

  Animation<double>? primaryAnimation;
  AnimationController? primaryAnimationController;
  final Duration singleAnimationDuration = Duration(milliseconds: 500);
  final ValueNotifier<List<_AnimationPart>?> animationsNotifier = ValueNotifier(
    null,
  );

  int? latestIndex;
  int? previousIndex;
  double? totalOffset;

  void rebuildAnimations(LyricOffsetDeltas deltas) {
    previousIndex = null;
    primaryAnimation = null;
    primaryAnimationController = null;

    double begin = deltas.begin.dy;
    final results = <_AnimationPart>[];

    for (int i = 0; i < deltas.deltas.length; i++) {
      final delta = deltas.deltas[i];
      final dy = delta.dy;

      double animationBegin = begin - dy;
      final animationEnd = begin;

      if (i >= 1) {
        final previousDelta = deltas.deltas[i - 1];
        final previousDy = previousDelta.dy;

        final extraDelta = (dy - previousDy).abs();
        if (previousDy > dy) {
          animationBegin = begin - dy - extraDelta;
        }
        if (previousDy < dy) {
          animationBegin = begin - dy + extraDelta;
        }
      }

      final controller = AnimationController(
        vsync: this,
        duration: singleAnimationDuration,
      );
      final animation = Tween(begin: animationBegin, end: animationEnd).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.fastEaseInToSlowEaseOut,
        ),
      );
      final animationPart = _AnimationPart(animation, controller);
      results.add(animationPart);

      begin = begin + dy;
    }

    if (results.isEmpty) {
      return;
    }

    primaryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: results.length * singleAnimationDuration.inMilliseconds,
      ),
    );
    primaryAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: primaryAnimationController!,
        curve: Zero2OneMutationCurve(
          List.generate(results.length, (index) => index.toDouble()),
        ),
      ),
    );
    animationsNotifier.value = results;

    if (latestIndex != null) {
      final k = 1 / widget.total;
      final target = k * latestIndex!;
      primaryAnimationController?.value = target;
    }
  }

  @override
  void initState() {
    super.initState();

    indexSubscription = widget.indexStream.listen((index) {
      latestIndex = index;
      if (index == null) {
        return;
      }
      final k = 1 / widget.total;
      final target = k * index;
      primaryAnimationController?.value = target;
    });

    offsetSubscription = widget.offsetStream.listen((deltas) {
      if (deltas == null) {
        return;
      }
      if (deltas.index != widget.index) {
        return;
      }
      rebuildAnimations(deltas);
    });

    durationSubscription = widget.durationStream.listen((animationDuration) {
      if (animationDuration == null) {
        return;
      }
      if (animationDuration.index != widget.index) {
        return;
      }
      final animations = animationsNotifier.value;
      if (animations == null) {
        return;
      }
      for (final part in animations) {
        part.controller.duration = animationDuration.duration;
      }
    });
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
        ),
      );
    }
    if (romanLyric != null) {
      romanLyricText = Text(
        romanLyric,
        softWrap: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24.sp,
          fontFamily: getFont(),
          fontFamilyFallback: getFallbackFonts(),
          shadows: [Shadow(blurRadius: 6)],
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
              shadows: [Shadow(blurRadius: 6)],
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

  Widget buildAlignedLyric() {
    final lyric = widget.lyric.text;
    final translatedLyric = widget.lyric.translatedText;
    final romanLyric = widget.lyric.romanText;

    Widget translatedLyricText = SizedBox.shrink();
    Widget romanLyricText = SizedBox.shrink();
    if (translatedLyric != null) {
      translatedLyricText = Text(
        translatedLyric,
        softWrap: true,

        style: TextStyle(
          fontSize: 24.sp,
          fontFamily: getFont(),
          fontFamilyFallback: getFallbackFonts(),
          shadows: [Shadow(blurRadius: 6)],
        ),
      );
    }
    if (romanLyric != null) {
      romanLyricText = Text(
        romanLyric,
        softWrap: true,
        style: TextStyle(
          fontSize: 24.sp,
          fontFamily: getFont(),
          fontFamilyFallback: getFallbackFonts(),
          shadows: [Shadow(blurRadius: 6)],
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
            style: TextStyle(
              fontSize: 32.sp,
              fontFamily: getFont(),
              fontFamilyFallback: getFallbackFonts(),
              shadows: [Shadow(blurRadius: 6)],
            ),
          ).applyConstraint(
            id: lyricId,
            top: parent.top,
            left: parent.left,
            width: widget.width ?? 240,
          ),
          romanLyricText.applyConstraint(
            id: romanId,
            top: lyricId.bottom,
            left: parent.left,
            width: widget.width ?? 240,
          ),
          translatedLyricText.applyConstraint(
            id: translatedId,
            top: romanId.bottom,
            left: parent.left,
            width: widget.width ?? 240,
          ),
          SizedBox().applyConstraint(
            top: translatedId.bottom,
            left: parent.left,
            height: 24.h,
          ),
        ],
      ),
    );
  }

  Widget buildLyric() {
    if (widget.display == null || widget.display == LyricDisplay.aligned) {
      return buildAlignedLyric();
    }
    return buildCenterLyric();
  }

  @override
  void dispose() {
    offsetSubscription?.cancel();
    offsetSubscription = null;
    indexSubscription?.cancel();
    indexSubscription = null;
    durationSubscription?.cancel();
    durationSubscription = null;
    primaryAnimation = null;
    primaryAnimationController?.dispose();
    primaryAnimationController = null;

    if (animationsNotifier.value != null) {
      for (final part in animationsNotifier.value!) {
        part.controller.dispose();
      }
      animationsNotifier.value!.clear();
    }

    animationsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: animationsNotifier,
      builder: (context, animations, _) {
        if (animations == null ||
            animations.isEmpty ||
            primaryAnimation == null ||
            primaryAnimationController == null) {
          return buildLyric();
        }

        return AnimatedBuilder(
          animation: primaryAnimation!,
          builder: (context, _) {
            final index = primaryAnimation?.value.toInt();
            if (index == null) {
              return buildLyric();
            }
            final part = animations[index];
            final animation = part.animation;

            if (previousIndex != null) {
              final delta = index - previousIndex!;

              if (delta > 1) {
                for (int i = index; i >= previousIndex!; i--) {
                  animations[i].controller.forward();
                }
              }
              if (delta < -1) {
                animations[index].controller.forward();
                for (int i = previousIndex!; i > index; i--) {
                  animations[i].controller.reverse();
                }
              }
              if (delta == -1) {
                animations[index].controller.forward();
                animations[previousIndex!].controller.reverse();
              }
              if (delta == 1) {
                part.controller.forward();
              }
            } else {
              part.controller.forward();
            }
            previousIndex = index;

            return AnimatedBuilder(
              animation: animation,
              builder: (_, __) {
                final translated = Transform.translate(
                  offset: Offset(0, animation.value),
                  child: buildLyric(),
                );

                final distance = (widget.index - index).abs();
                double k1 = 1 / distance;
                if (distance == 0) {
                  k1 = 1;
                }
                if (distance == 1) {
                  k1 = 0.6;
                }

                return AnimatedOpacity(
                  opacity: k1,
                  duration: Duration(milliseconds: 250),
                  child: translated,
                );
              },
            );
          },
        );
      },
    );
  }
}
