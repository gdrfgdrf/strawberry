import 'dart:async';
import 'dart:io';

import 'package:find_size/find_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:widgets/widgets/animated_char_text.dart';
import 'package:widgets/widgets/nextlyrics/next_lyrics_calculator.dart';

import '../animated_blur.dart';

class CalculatedWordBasedLyrics {
  final int centerIndex;
  final int wordIndex;
  final List<CalculatedLyric> offsets;
  final List<WordInfo> wordInfos;

  const CalculatedWordBasedLyrics(
    this.centerIndex,
    this.wordIndex,
    this.offsets,
    this.wordInfos,
  );
}

class AnimatedPositionedWordBasedLyric extends StatefulWidget {
  final double? width;
  final void Function(Size)? onSizeCompleted;
  final VoidCallback? onClicked;

  final Stream<CalculatedWordBasedLyrics?> calculateStream;

  final int index;
  final int total;
  final CombinedLyric lyric;

  final ColorScheme? colorScheme;

  const AnimatedPositionedWordBasedLyric({
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
  State<StatefulWidget> createState() => _AnimatedPositionedWordBasedLyric();
}

class _AnimatedPositionedWordBasedLyric
    extends State<AnimatedPositionedWordBasedLyric> {
  final List<StreamSubscription> subscriptions = [];
  int? centerIndex;
  CalculatedLyric? calculatedLyric;

  List<CharData> chars = [];
  int previousWordIndex = 0;

  @override
  void initState() {
    super.initState();

    final calculateSubscription = widget.calculateStream.listen((
      calculatedWordBasedLyrics,
    ) {
      if (calculatedWordBasedLyrics == null) {
        return;
      }

      centerIndex = calculatedWordBasedLyrics.centerIndex;
      calculatedLyric = calculatedWordBasedLyrics.offsets[widget.index];
      if (calculatedLyric == null) {
        return;
      }

      if (centerIndex != widget.index) {
        for (final char in chars) {
          char.status = CharStatus.down;
        }
      } else {
        final wordBasedLyric = widget.lyric.wordBasedLyric;
        final wordInfos = wordBasedLyric?.wordInfos;
        updateChars(
          calculatedWordBasedLyrics.wordIndex,
          CharStatus.up,
          wordInfos,
        );
      }

      setState(() {});
    });
    subscriptions.add(calculateSubscription);

    final wordBasedLyric = widget.lyric.wordBasedLyric;
    if (wordBasedLyric == null) {
      return;
    }
    final wordInfos = wordBasedLyric.wordInfos;
    if (wordInfos == null) {
      return;
    }
    chars =
        wordInfos
            .map((wordInfo) => CharData(wordInfo.word, CharStatus.down))
            .toList();
  }

  void updateChars(int wordIndex, CharStatus status, List<WordInfo>? wordInfos) {
    if (wordIndex <= -1 || wordIndex >= chars.length) {
      if (wordIndex <= -1) {
        final allDownTest =
            chars.fold(
              0,
              (previousValue, element) =>
                  previousValue + (element.status == CharStatus.down ? 0 : 1),
            ) ==
            0;
        if (allDownTest) {
          return;
        }
      }
      if (wordIndex >= chars.length) {
        final allUpTest =
            chars.fold(
              0,
              (previousValue, element) =>
                  previousValue + (element.status == CharStatus.up ? 0 : 1),
            ) ==
            0;
        if (allUpTest) {
          return;
        }
      }

      CharStatus status = CharStatus.down;
      if (wordIndex >= chars.length) {
        status = CharStatus.up;
      }
      for (final char in chars) {
        char.status = status;
      }
      return;
    }
    if (wordIndex >= 0 && wordIndex < chars.length) {
      if (wordIndex <= 0) {
        previousWordIndex = wordIndex;
        chars[wordIndex] = CharData(chars[wordIndex].char, status);
        return;
      }
      if (wordIndex == previousWordIndex) {
        return;
      }
      if (wordIndex > previousWordIndex) {
        int traceBackWordIndex = previousWordIndex;

        if (traceBackWordIndex > 0) {
          for (int i = wordIndex - 1; i >= 0; i--) {
            final traceChar = chars[i];
            if (traceChar.status == status) {
              if (i < traceBackWordIndex) {
                traceBackWordIndex = i;
              }
            }
          }
        }
        for (int i = traceBackWordIndex; i <= wordIndex; i++) {
          chars[i].status = status;
          if (wordInfos != null && wordInfos.isNotEmpty == true) {
            chars[i].duration = wordInfos[i].duration + Duration(milliseconds: 500);
          }
        }
      } else {
        if (wordIndex <= chars.length - 1) {
          int traceForwardWordIndex = previousWordIndex;

          for (int i = wordIndex + 1; i < chars.length; i++) {
            final traceChar = chars[i];
            if (traceChar.status == status) {
              if (i > traceForwardWordIndex) {
                traceForwardWordIndex = i;
              }
            }
          }
          final flippedStatus =
              status == CharStatus.up ? CharStatus.down : CharStatus.up;
          for (int i = wordIndex + 1; i <= traceForwardWordIndex; i++) {
            chars[i].status = flippedStatus;
            if (wordInfos != null && wordInfos.isNotEmpty == true) {
              chars[i].duration = wordInfos[i].duration + Duration(milliseconds: 500);
            }
          }
        } else {
          for (final char in chars) {
            char.status = status;
          }
        }
      }
    }
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

  Widget buildWordBasedText(String? text) {
    if (widget.lyric.wordBasedLyric == null) {
      return SizedBox.shrink();
    }
    final wordInfos = widget.lyric.wordBasedLyric!.wordInfos;
    if (wordInfos == null) {
      return SizedBox.shrink();
    }

    return AnimatedWordBasedText(
      chars: chars,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32.sp,
        fontFamily: getFont(),
        fontFamilyFallback: getFallbackFonts(),
        shadows: [Shadow(blurRadius: 12)],
        fontWeight: FontWeight.bold,
        color: widget.colorScheme?.secondaryContainer,
      ),
      wrapAlignment: WrapAlignment.center,
    );
  }

  Widget buildCenterLyric() {
    if (widget.lyric.wordBasedLyric == null) {
      return SizedBox.shrink();
    }
    final wordInfos = widget.lyric.wordBasedLyric!.wordInfos;
    if (wordInfos == null) {
      return SizedBox.shrink();
    }

    final lyric = wordInfos
        .map((wordInfo) => wordInfo.word)
        .toList()
        .fold("", (previous, element) => "$previous$element");
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
          buildWordBasedText(lyric).applyConstraint(
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

class AnimatedWordBasedText extends StatefulWidget {
  final List<CharData> chars;

  final TextAlign? textAlign;
  final TextStyle? style;

  final Axis wrapDirection;
  final WrapAlignment wrapAlignment;
  final double wrapSpacing;
  final WrapAlignment wrapRunAlignment;
  final double wrapRunSpacing;
  final WrapCrossAlignment wrapCrossAlignment;
  final TextDirection? wrapTextDirection;
  final VerticalDirection wrapVerticalDirection;
  final Clip wrapClipBehavior;

  const AnimatedWordBasedText({
    super.key,
    required this.chars,
    this.textAlign,
    this.style,
    this.wrapDirection = Axis.horizontal,
    this.wrapAlignment = WrapAlignment.start,
    this.wrapSpacing = 0.0,
    this.wrapRunAlignment = WrapAlignment.start,
    this.wrapRunSpacing = 0.0,
    this.wrapCrossAlignment = WrapCrossAlignment.start,
    this.wrapTextDirection,
    this.wrapVerticalDirection = VerticalDirection.down,
    this.wrapClipBehavior = Clip.none,
  });

  @override
  State<StatefulWidget> createState() => _AnimatedWordBasedTextState();
}

class _AnimatedWordBasedTextState extends State<AnimatedWordBasedText> {
  @override
  Widget build(BuildContext context) {
    return AnimatedCharText(
      chars: widget.chars,
      textAlign: widget.textAlign ?? TextAlign.center,
      softWrap: true,
      style: widget.style,
      wrapDirection: widget.wrapDirection,
      wrapAlignment: widget.wrapAlignment,
      wrapSpacing: widget.wrapSpacing,
      wrapRunAlignment: widget.wrapRunAlignment,
      wrapRunSpacing: widget.wrapRunSpacing,
      wrapCrossAlignment: widget.wrapCrossAlignment,
      wrapTextDirection: widget.wrapTextDirection,
      wrapVerticalDirection: widget.wrapVerticalDirection,
      wrapClipBehavior: widget.wrapClipBehavior,
    );
  }
}
