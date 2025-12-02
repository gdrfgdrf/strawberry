import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:shared/lyric/next/next_lyric_scheduler.dart';
import 'package:shared/lyric/next/next_word_based_lyric_corrector.dart';
import 'package:widgets/widgets/nextlyrics/next_smooth_lyrics.dart';
import 'package:widgets/widgets/scrollable_lyrics.dart';

class SmoothLyrics extends StatefulWidget {
  final Stream<LyricsContainer?> lyricsStream;
  final Stream<Duration> positionStream;
  final Stream<ColorScheme?>? colorSchemeStream;

  final double? width;
  final double? height;

  final double? lyricWidth;
  final double? lyricHeight;
  final LyricDisplay? lyricDisplay;

  final void Function(int, CombinedLyric)? onClicked;

  const SmoothLyrics({
    super.key,
    required this.lyricsStream,
    required this.positionStream,
    this.colorSchemeStream,
    this.width,
    this.height,
    this.lyricWidth,
    this.lyricHeight,
    this.lyricDisplay,
    this.onClicked,
  });

  @override
  State<StatefulWidget> createState() => _SmoothLyricsState();
}

class _SmoothLyricsState extends State<SmoothLyrics> {
  NextRawLyricScheduler? lyricScheduler;
  NextWordBasedLyricScheduler? wordBasedLyricScheduler;

  StreamSubscription? lyricSchedulerSubscription;
  List<StreamSubscription> subscriptions = [];

  BehaviorSubject<int?>? indexSubject = BehaviorSubject.seeded(0);
  BehaviorSubject<(int?, int?)?>? wordBasedIndexSubject =
      BehaviorSubject.seeded(null);

  @override
  void initState() {
    super.initState();

    final lyricsSubscription = widget.lyricsStream.listen((lyricsContainer) {
      lyricScheduler?.dispose();
      lyricScheduler = null;
      lyricSchedulerSubscription?.cancel();
      lyricSchedulerSubscription = null;

      if (lyricsContainer == null) {
        return;
      }

      if (!shouldWordBased(lyricsContainer)) {
        final combined = lyricsContainer.combine();
        if (combined == null) {
          return;
        }

        prepareForRaw(combined);
        return;
      }
      prepareForWordBased(lyricsContainer);
    });
    subscriptions.add(lyricsSubscription);
  }

  bool shouldWordBased(LyricsContainer container) {
    if (container.wordBasedLyrics == null ||
        container.wordBasedLyrics?.isEmpty == true) {
      return false;
    }
    if (container.wordBasedLyrics!.length > container.dataCount) {
      return true;
    }
    return false;
  }

  void prepareForRaw(List<CombinedLyric> combined) {
    lyricScheduler = NextRawLyricScheduler(combined, widget.positionStream);
    lyricScheduler!.prepare();
    lyricScheduler!.start();
    lyricSchedulerSubscription = lyricScheduler!.lyricSubject?.listen((
      scheduledLyric,
    ) {
      if (scheduledLyric == null) {
        return;
      }

      indexSubject?.add(scheduledLyric.index);
    });
  }

  void prepareForWordBased(LyricsContainer container) {
    wordBasedLyricScheduler = NextWordBasedLyricScheduler(
      container,
      widget.positionStream,
    );
    wordBasedLyricScheduler!.prepare();
    wordBasedLyricScheduler!.start();
    lyricSchedulerSubscription = wordBasedLyricScheduler!.lyricSubject?.listen((
      scheduledWordBasedLyric,
    ) {
      if (scheduledWordBasedLyric == null) {
        return;
      }
      wordBasedIndexSubject?.add((
        scheduledWordBasedLyric.index,
        scheduledWordBasedLyric.wordIndex,
      ));
    });
  }

  @override
  void dispose() {
    lyricScheduler?.dispose();
    lyricScheduler = null;
    wordBasedLyricScheduler?.dispose();
    wordBasedLyricScheduler = null;
    lyricSchedulerSubscription?.cancel();
    lyricSchedulerSubscription = null;
    indexSubject?.close();
    indexSubject = null;
    wordBasedIndexSubject?.close();
    wordBasedIndexSubject = null;
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
    super.dispose();
  }

  Widget internalBuild(
    LyricsContainer? lyricsContainer,
    ColorScheme? colorScheme,
  ) {
    if (lyricsContainer == null) {
      return SizedBox.shrink();
    }
    if (!shouldWordBased(lyricsContainer)) {
      lyricsContainer.wordBasedLyrics?.clear();

      final combined = lyricsContainer.combine();
      if (combined == null) {
        return SizedBox.shrink();
      }

      return ClipRect(
        child: NextSmoothLyrics(
          lyrics: combined,
          indexStream: indexSubject!.stream,
          width: widget.width,
          height: widget.height,
          lyricWidth: widget.lyricWidth,
          colorScheme: colorScheme,
          onLyricClicked: (index) {
            widget.onClicked?.call(index, combined[index]);
          },
        ),
      );
    }

    final corrected = NextWordBasedLyricCorrector.correctLyrics(
      lyricsContainer,
    );
    if (corrected == null) {
      return SizedBox.shrink();
    }

    return ClipRect(
      child: NextSmoothWordBasedLyrics(
        lyricsContainer: lyricsContainer,
        indexStream: wordBasedIndexSubject!.stream,
        width: widget.width,
        height: widget.height,
        lyricWidth: widget.lyricWidth,
        colorScheme: colorScheme,
        onLyricClicked: (index) {
          widget.onClicked?.call(index, corrected[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      indexSubject?.add(indexSubject?.valueOrNull);
    });

    if (widget.colorSchemeStream == null) {
      return StreamBuilder(
        stream: widget.lyricsStream,
        builder: (context, data) {
          if (!data.hasData) {
            return SizedBox.shrink();
          }
          return internalBuild(data.data!, null);
        },
      );
    }

    return StreamBuilder(
      stream: Rx.combineLatest2(
        widget.lyricsStream,
        widget.colorSchemeStream!,
        (a, b) => (a, b),
      ),
      builder: (context, combinedData) {
        if (!combinedData.hasData) {
          return SizedBox.shrink();
        }

        final lyricsContainer = combinedData.data!.$1;
        final colorScheme = combinedData.data!.$2;

        return internalBuild(lyricsContainer, colorScheme);
      },
    );
  }
}
