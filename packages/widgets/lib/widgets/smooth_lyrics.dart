import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:shared/lyric/lyric_scheduler.dart';
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
  LyricScheduler? lyricScheduler;
  StreamSubscription? lyricSchedulerSubscription;
  List<StreamSubscription> subscriptions = [];

  BehaviorSubject<int?>? indexSubject = BehaviorSubject.seeded(null);
  BehaviorSubject<double?>? scrollSubject = BehaviorSubject.seeded(null);

  @override
  void initState() {
    super.initState();

    final lyricsSubscription = widget.lyricsStream.listen((lyricsContainer) {
      if (lyricsContainer == null) {
        lyricSchedulerSubscription?.cancel();
        lyricSchedulerSubscription = null;
        lyricScheduler?.dispose();
        lyricScheduler = null;
        return;
      }

      lyricsContainer.wordBasedLyrics?.clear();
      final combined = lyricsContainer.combine();
      if (combined == null) {
        lyricSchedulerSubscription?.cancel();
        lyricSchedulerSubscription = null;
        lyricScheduler?.dispose();
        lyricScheduler = null;
        return;
      }

      lyricScheduler?.dispose();
      lyricScheduler = null;
      lyricSchedulerSubscription?.cancel();
      lyricSchedulerSubscription = null;

      lyricScheduler = LyricScheduler(combined, widget.positionStream);
      lyricScheduler!.start();
      lyricSchedulerSubscription = lyricScheduler!.lyricStream.listen((
        lyricStreamData,
      ) {
        if (lyricStreamData == null) {
          return;
        }

        indexSubject?.add(lyricStreamData.index);
      });
    });
    subscriptions.add(lyricsSubscription);
  }

  @override
  void dispose() {
    lyricScheduler?.dispose();
    lyricScheduler = null;
    lyricSchedulerSubscription?.cancel();
    lyricSchedulerSubscription = null;
    indexSubject?.close();
    indexSubject = null;
    scrollSubject?.close();
    scrollSubject = null;
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      indexSubject?.add(indexSubject?.valueOrNull);
    });

    return StreamBuilder(
      stream: Rx.combineLatest2(
        widget.lyricsStream,
        widget.colorSchemeStream ?? Stream.empty(),
        (a, b) => (a, b),
      ),
      builder: (context, combinedData) {
        if (!combinedData.hasData) {
          return SizedBox.shrink();
        }

        final lyricsContainer = combinedData.data!.$1;
        final colorScheme = combinedData.data!.$2;

        if (lyricsContainer == null) {
          return SizedBox.shrink();
        }
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

        return ClipRect(
          child: ScrollableLyrics(
            width: widget.width,
            height: widget.height,
            lyrics: combined,
            indexStream: indexSubject!.stream,
            lyricWidth: widget.lyricWidth,
            lyricDisplay: widget.lyricDisplay,
            colorScheme: colorScheme,
            onLyricClicked: (index) {
              widget.onClicked?.call(index, combined[index]);
            },
          ),
        );
      },
    );
  }
}
