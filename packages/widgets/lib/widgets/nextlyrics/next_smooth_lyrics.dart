import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:shared/lyric/next/next_word_based_lyric_corrector.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:widgets/widgets/nextlyrics/animated_positioned_word_based_lyric.dart';
import 'package:widgets/widgets/nextlyrics/next_lyrics_calculator.dart';

import 'animated_positioned_lyric.dart';

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

class NextSmoothWordBasedLyrics extends StatefulWidget {
  final double? width;
  final double? height;
  final double? gap;

  final double? lyricWidth;

  final LyricsContainer lyricsContainer;
  final Stream<(int? lyricIndex, int? wordIndex)?> indexStream;

  final ColorScheme? colorScheme;

  final void Function(int)? onLyricClicked;

  const NextSmoothWordBasedLyrics({
    super.key,
    this.width,
    this.height,
    this.gap,
    this.lyricWidth,
    required this.lyricsContainer,
    required this.indexStream,
    this.colorScheme,
    this.onLyricClicked,
  });

  @override
  State<StatefulWidget> createState() => _NextSmoothWordBasedLyrics();
}

class _NextSmoothWordBasedLyrics extends State<NextSmoothWordBasedLyrics> {
  List<CombinedLyric>? lyrics;

  bool allSizeCompleted = false;
  List<RenderedLyric> renderedLyrics = [];

  BehaviorSubject<CalculatedWordBasedLyrics?> calculateStream =
      BehaviorSubject.seeded(null);
  StreamSubscription? indexSubscription;

  void onAllSizeCompleted() {
    renderedLyrics.sort((a, b) => a.index.compareTo(b.index));

    final screenSize = MediaQuery.of(context).size;
    indexSubscription = widget.indexStream.listen((pair) {
      final lyricIndex = pair?.$1 ?? 0;
      int? wordIndex = pair?.$2 ?? -1;

      final lyric = lyrics![lyricIndex];
      final wordBasedLyric = lyric.wordBasedLyric;
      List<WordInfo> wordInfos = wordBasedLyric?.wordInfos ?? [];

      final calculatedLyrics = LyricCalculator.offsets(
        renderedLyrics,
        lyricIndex,
        widget.height ?? screenSize.height,
        0,
      );
      final calculatedWordBasedLyrics = CalculatedWordBasedLyrics(
        lyricIndex,
        wordIndex,
        calculatedLyrics.offsets,
        wordInfos,
      );
      calculateStream.add(calculatedWordBasedLyrics);
    });
  }

  void onSizeCompleted(int index, Size size) {
    if (allSizeCompleted) {
      return;
    }

    final renderedLyric = RenderedLyric(index, size, lyrics![index]);
    renderedLyrics.add(renderedLyric);
    if (renderedLyrics.length >= lyrics!.length) {
      onAllSizeCompleted();
    }
  }

  @override
  void dispose() {
    lyrics?.clear();
    lyrics = null;
    renderedLyrics.clear();
    calculateStream.close();
    indexSubscription?.cancel();
    indexSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    lyrics?.clear();
    lyrics = NextWordBasedLyricCorrector.correctLyrics(widget.lyricsContainer);
    allSizeCompleted = false;
    renderedLyrics.clear();
    indexSubscription?.cancel();
    indexSubscription = null;

    if (lyrics == null || lyrics?.isEmpty == true) {
      return SizedBox.shrink();
    }

    final widgets = <Widget>[];
    for (int i = 0; i < lyrics!.length; i++) {
      final lyric = lyrics![i];
      widgets.add(
        AnimatedPositionedWordBasedLyric(
          key: UniqueKey(),
          width: widget.lyricWidth,
          calculateStream: calculateStream,
          index: i,
          total: lyrics!.length,
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
