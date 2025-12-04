import 'dart:math';
import 'dart:ui';

import 'package:shared/lyric/lyric_parser.dart';

class RenderedLyric {
  final int index;
  final Size size;
  final CombinedLyric lyric;

  const RenderedLyric(this.index, this.size, this.lyric);
}

class CalculatedLyric {
  final Offset offset;
  final RenderedLyric renderedLyric;
  final Duration duration;

  const CalculatedLyric(this.offset, this.renderedLyric, this.duration);
}

class CalculatedLyrics {
  final int centerIndex;
  final List<CalculatedLyric> offsets;

  const CalculatedLyrics(this.centerIndex, this.offsets);
}

class LyricCalculator {
  static CalculatedLyrics offsets(
    List<RenderedLyric> lyrics,
    int centerIndex,
    double containerHeight,
    double gap, {
    bool fixedDuration = false,
  }) {
    final reversedPreviousLyrics =
        lyrics.sublist(0, centerIndex).reversed.toList();
    final nextLyrics = lyrics.sublist(centerIndex + 1, lyrics.length);
    final centerLyric = lyrics[centerIndex];
    List<CalculatedLyric> results = [];

    final centerDy =
        (2.35 / 5) * containerHeight - (1 / 2) * centerLyric.size.height;

    double previousCumulativeDy = centerDy - gap;
    for (int i = 0; i < reversedPreviousLyrics.length; i++) {
      final distance = -(i + 1);
      final lyric = reversedPreviousLyrics[i];

      Duration duration;
      if (fixedDuration) {
        duration = const Duration(milliseconds: 500);
      } else {
        duration = Duration(milliseconds: (500 * sqrt(-distance)).toInt());
      }

      previousCumulativeDy -= lyric.size.height;
      final calculated = CalculatedLyric(
        Offset(0, previousCumulativeDy),
        lyric,
        duration,
      );
      results.add(calculated);
    }
    results = results.reversed.toList();

    results.add(
      CalculatedLyric(
        Offset(0, centerDy),
        centerLyric,
        Duration(milliseconds: 600),
      ),
    );

    double nextCumulativeDy = centerDy + centerLyric.size.height + gap;
    for (int i = 0; i < nextLyrics.length; i++) {
      final distance = i + 1;
      final lyric = nextLyrics[i];

      Duration duration;
      if (fixedDuration) {
        duration = const Duration(milliseconds: 500);
      } else {
        duration = Duration(
          milliseconds: (500 * sqrt(distance) * pow(1.3, distance)).toInt(),
        );
      }

      final calculated = CalculatedLyric(
        Offset(0, nextCumulativeDy),
        lyric,
        duration,
      );
      results.add(calculated);
      nextCumulativeDy += lyric.size.height + gap;
    }

    return CalculatedLyrics(centerIndex, results);
  }
}
