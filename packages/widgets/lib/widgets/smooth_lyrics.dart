import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:shared/lyric/lyric_scheduler.dart';
import 'package:widgets/widgets/scrollable_lyrics.dart';

// class Lyric extends StatefulWidget {
//   final double? width;
//   final double? height;
//   final TextAlign? textAlign;
//   final EdgeInsets? padding;
//
//   final MainAxisAlignment? mainAxisAlignment;
//   final CrossAxisAlignment? crossAxisAlignment;
//
//   final VoidCallback? onClick;
//
//   final int index;
//   final CombinedLyric lyric;
//   final Stream<int?> indexStream;
//
//   final double scrollPosition;
//   final double scrollLength;
//   final Stream<double?> scrollStream;
//
//   final Duration duration;
//   final ScaleRatio? scaleRatio;
//   final Alignment? animationAlignment;
//
//   const Lyric({
//     super.key,
//     this.width,
//     this.height,
//     this.textAlign,
//     this.padding,
//     this.mainAxisAlignment,
//     this.crossAxisAlignment,
//     this.onClick,
//     required this.index,
//     required this.lyric,
//     required this.indexStream,
//     required this.scrollPosition,
//     required this.scrollLength,
//     required this.scrollStream,
//     this.duration = const Duration(milliseconds: 500),
//     this.scaleRatio,
//     this.animationAlignment,
//   });
//
//   @override
//   State<StatefulWidget> createState() => _LyricState();
// }
//
// class _LyricState extends State<Lyric> with TickerProviderStateMixin {
//   StreamSubscription? indexSubscription;
//   StreamSubscription? scrollSubscription;
//   AnimationController? animationController;
//   Animation<double>? scaleAnimation;
//   ValueNotifier<double>? opacityNotifier = ValueNotifier(0.0);
//
//   @override
//   void initState() {
//     super.initState();
//
//     animationController = AnimationController(
//       vsync: this,
//       duration: widget.duration,
//     );
//     scaleAnimation = Tween(
//       begin: widget.scaleRatio?.before ?? 0.8,
//       end: widget.scaleRatio?.after ?? 1.0,
//     ).animate(
//       CurvedAnimation(
//         parent: animationController!,
//         curve: Curves.fastEaseInToSlowEaseOut,
//       ),
//     );
//     indexSubscription = widget.indexStream.listen((targetIndex) {
//       if (targetIndex == null) {
//         animationController?.reverse();
//         return;
//       }
//
//       if (targetIndex == widget.index) {
//         animationController?.forward();
//         return;
//       }
//       animationController?.reverse();
//     });
//     scrollSubscription = widget.scrollStream.listen((offset) {
//       if (offset == null) {
//         return;
//       }
//
//       final a = (widget.scrollPosition - offset).abs();
//       final k = 1 / widget.scrollLength;
//       final opacity = 1 - k * a * 5;
//       if (opacity <= 0) {
//         opacityNotifier?.value = min(0, -opacity);
//       } else {
//         opacityNotifier?.value = min(1, opacity);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     indexSubscription?.cancel();
//     indexSubscription = null;
//     scrollSubscription?.cancel();
//     scrollSubscription = null;
//     animationController?.dispose();
//     animationController = null;
//     scaleAnimation = null;
//     opacityNotifier?.dispose();
//     super.dispose();
//   }
//
//   Widget buildLyric(CombinedLyric combinedLyric) {
//     final lyric = combinedLyric.text;
//     final translatedLyric = combinedLyric.translatedText;
//     final romanLyric = combinedLyric.romanText;
//
//     if (lyric == null) {
//       return SizedBox.shrink();
//     }
//     Widget translatedLyricText = SizedBox.shrink();
//     Widget romanLyricText = SizedBox.shrink();
//     if (translatedLyric != null) {
//       translatedLyricText = Text(
//         translatedLyric,
//         softWrap: true,
//         textAlign: widget.textAlign,
//         style: TextStyle(fontSize: 24.sp, shadows: [Shadow(blurRadius: 6)]),
//       );
//     }
//     if (romanLyric != null) {
//       romanLyricText = Text(
//         romanLyric,
//         softWrap: true,
//         textAlign: widget.textAlign,
//         style: TextStyle(fontSize: 24.sp, shadows: [Shadow(blurRadius: 6)]),
//       );
//     }
//
//     return GestureDetector(
//       onTap: () {
//         widget.onClick?.call();
//       },
//       child: AnimatedHoverWidget(
//         width: widget.width ?? 240,
//         height: widget.height,
//         borderRadius: BorderRadius.circular(16),
//         hoverColor: themeData().colorScheme.surfaceBright.withAlpha(120),
//         main:
//             SmoothContainer(
//                   width: widget.width ?? 240,
//                   height: widget.height,
//                   child: Column(
//                     mainAxisAlignment:
//                         widget.mainAxisAlignment ?? MainAxisAlignment.center,
//                     crossAxisAlignment:
//                         widget.crossAxisAlignment ?? CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         lyric,
//                         softWrap: true,
//                         textAlign: widget.textAlign,
//                         style: TextStyle(
//                           fontSize: 32.sp,
//                           shadows: [Shadow(blurRadius: 6)],
//                         ),
//                       ),
//                       romanLyricText,
//                       translatedLyricText,
//                     ],
//                   ),
//                 ).applyConstraint(left: parent.left, top: parent.top)
//                 as Constrained,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: opacityNotifier!,
//       builder: (context, opacity, _) {
//         return Opacity(
//           opacity: opacity,
//           child: ScaleTransition(
//             alignment: widget.animationAlignment ?? Alignment.centerLeft,
//             scale: scaleAnimation!,
//             child: buildLyric(widget.lyric),
//           ),
//         );
//       },
//     );
//   }
// }

class SmoothLyrics extends StatefulWidget {
  final Stream<LyricsContainer?> lyricsStream;
  final Stream<Duration> positionStream;

  final double? lyricWidth;
  final double? lyricHeight;
  final MainAxisAlignment? lyricMainAxisAlignment;
  final CrossAxisAlignment? lyricCrossAxisAlignment;
  final TextAlign? lyricTextAlign;

  final void Function(int, CombinedLyric)? onClicked;

  const SmoothLyrics({
    super.key,
    required this.lyricsStream,
    required this.positionStream,
    this.lyricWidth,
    this.lyricHeight,
    this.lyricMainAxisAlignment,
    this.lyricCrossAxisAlignment,
    this.lyricTextAlign,
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

        return ClipRect(
          child: ScrollableLyrics(
            lyrics: combined,
            indexStream: indexSubject!.stream,
            lyricWidth: widget.lyricWidth,
            lyricMainAxisAlignment: widget.lyricMainAxisAlignment,
            lyricCrossAxisAlignment: widget.lyricCrossAxisAlignment,
            lyricTextAlign: widget.lyricTextAlign,
            onLyricClicked: (index) {
              widget.onClicked?.call(index, combined[index]);
            },
          ),
        );
      },
    );
  }
}
