import 'dart:async';

import 'package:anchor_scroll_controller/anchor_scroll_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:shared/lyric/lyric_scheduler.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:widgets/widgets/animated_hover_widget.dart';

class SmoothLyrics extends StatefulWidget {
  final Stream<LyricsContainer?> lyricsStream;
  final Stream<Duration> positionStream;

  final double? lyricWidth;
  final double? lyricHeight;
  final MainAxisAlignment? lyricMainAxisAlignment;
  final CrossAxisAlignment? lyricCrossAxisAlignment;
  final TextAlign? textAlign;

  final void Function(Duration)? onSeekPosition;

  const SmoothLyrics({
    super.key,
    required this.lyricsStream,
    required this.positionStream,
    this.lyricWidth,
    this.lyricHeight,
    this.lyricMainAxisAlignment,
    this.lyricCrossAxisAlignment,
    this.textAlign,
    this.onSeekPosition
  });

  @override
  State<StatefulWidget> createState() => _SmoothLyricsState();
}

class _SmoothLyricsState extends State<SmoothLyrics> {
  LyricScheduler? lyricScheduler;
  StreamSubscription? lyricSchedulerSubscription;
  BehaviorSubject<int?>? indexSubject = BehaviorSubject.seeded(null);
  AnchorScrollController? scrollController;
  List<StreamSubscription> subscriptions = [];

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

        scrollController?.scrollToIndex(
          index: lyricStreamData.index,
          curve: Curves.fastEaseInToSlowEaseOut,
        );
        indexSubject?.add(lyricStreamData.index);
      });
    });
    subscriptions.add(lyricsSubscription);
  }

  Widget buildLyric(CombinedLyric combinedLyric) {
    final lyric = combinedLyric.text;
    final translatedLyric = combinedLyric.translatedText;
    final romanLyric = combinedLyric.romanText;

    if (lyric == null) {
      return SizedBox.shrink();
    }
    Widget translatedLyricText = SizedBox.shrink();
    Widget romanLyricText = SizedBox.shrink();
    if (translatedLyric != null) {
      translatedLyricText = Text(
        translatedLyric,
        softWrap: true,
        textAlign: widget.textAlign,
        style: TextStyle(fontSize: 24.sp, shadows: [Shadow(blurRadius: 6)]),
      );
    }
    if (romanLyric != null) {
      romanLyricText = Text(
        romanLyric,
        softWrap: true,
        textAlign: widget.textAlign,
        style: TextStyle(fontSize: 24.sp, shadows: [Shadow(blurRadius: 6)]),
      );
    }

    return GestureDetector(
      onTap: () {
        final position = combinedLyric.position;
        widget.onSeekPosition?.call(position);
      },
      child: AnimatedHoverWidget(
        width: widget.lyricWidth ?? 240,
        height: widget.lyricHeight,
        borderRadius: BorderRadius.circular(16),
        hoverColor: themeData().colorScheme.surfaceBright.withAlpha(120),
        main:
        SmoothContainer(
          width: widget.lyricWidth ?? 240,
          height: widget.lyricHeight,
          child: Column(
            mainAxisAlignment:
            widget.lyricMainAxisAlignment ?? MainAxisAlignment.center,
            crossAxisAlignment:
            widget.lyricCrossAxisAlignment ??
                CrossAxisAlignment.start,
            children: [
              Text(
                lyric,
                softWrap: true,
                textAlign: widget.textAlign,
                style: TextStyle(
                  fontSize: 32.sp,
                  shadows: [Shadow(blurRadius: 6)],
                ),
              ),
              romanLyricText,
              translatedLyricText,
            ],
          ),
        ).applyConstraint(left: parent.left, top: parent.top)
        as Constrained,
      ),
    );
  }

  @override
  void dispose() {
    lyricScheduler?.dispose();
    lyricScheduler = null;
    lyricSchedulerSubscription?.cancel();
    lyricSchedulerSubscription = null;
    indexSubject?.close();
    indexSubject = null;
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
    scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.lyricsStream,
      builder: (context, lyricsData) {
        if (!lyricsData.hasData) {
          return SizedBox.shrink();
        }
        final lyricsContainer = lyricsData.data!;
        lyricsContainer.wordBasedLyrics?.clear();

        final combined = lyricsContainer.combine();
        if (combined == null) {
          return SizedBox.shrink();
        }

        scrollController = null;
        scrollController = AnchorScrollController();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final latest = indexSubject?.value;
          if (latest != null) {
            scrollController?.scrollToIndex(
              index: latest,
              curve: Curves.fastEaseInToSlowEaseOut,
            );
          }
        });

        return SmoothListView.builder(
          key: UniqueKey(),
          physics: BouncingScrollPhysics(),
          controller: scrollController,
          itemCount: combined.length,
          duration: Duration(milliseconds: 500),
          itemBuilder: (context, index) {
            return AnchorItemWrapper(
              index: index,
              controller: scrollController,
              child: buildLyric(combined[index]),
            );
          },
        );
      },
    );
  }
}
