import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pair/pair.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/play/operator/audio_operator.dart';
import 'package:strawberry/play/song_chips.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/playing/playing_page_controller.dart';
import 'package:widgets/animation/overflow_widget_wrapper.dart';
import 'package:widgets/widgets/next_smooth_image.dart';
import 'package:widgets/widgets/smooth_linear_progress_indicator.dart';
import 'package:widgets/widgets/smooth_stream_builder.dart';

import '../audio_player_translator.dart';

class NextSongBarDesktop extends AbstractUiWidget {
  final AudioPlayer audioPlayer;

  const NextSongBarDesktop({super.key, required this.audioPlayer});

  @override
  State<StatefulWidget> createState() => _NextSongBarDesktopState();
}

class _NextSongBarDesktopState
    extends AbstractUiWidgetState<NextSongBarDesktop, EmptyDelegate>
    with TickerProviderStateMixin {
  final List<StreamSubscription> subscriptions = [];
  final ValueNotifier<List<int>?> coverNotifier = ValueNotifier(null);
  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);
  AudioPlayerTranslator? audioPlayerTranslator;

  @override
  EmptyDelegate createDelegate() {
    return EmptyDelegate.instance;
  }

  @override
  void initState() {
    super.initState();
    audioPlayerTranslator = AudioPlayerTranslator(widget.audioPlayer);
  }

  @override
  List<VoidCallback> postListeners() {
    return [
      () {
        audioPlayerTranslator!.start();
        final coverSubscription = audioPlayerTranslator!.coverStream().listen((
          bytes,
        ) {
          coverNotifier.value = bytes;
        });
        final positionSubscription = audioPlayerTranslator!
            .audioPlayer
            .positionStream
            .listen((position) {
              positionNotifier.value = position;
            });
        subscriptions.add(coverSubscription);
        subscriptions.add(positionSubscription);
      },
    ];
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    coverNotifier.dispose();
    positionNotifier.dispose();
    audioPlayerTranslator?.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    final coverId = ConstraintId("cover");
    final nameId = ConstraintId("name");

    return SmoothContainer(
      width: 1440.w,
      height: 64.w + 56.h,
      borderRadius: BorderRadius.circular(16),
      color: themeData().colorScheme.surfaceContainer,
      child: ConstraintLayout(
        children: [
          SmoothContainer(
            width: 64.w,
            height: 64.w,
            color: themeData().colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            child: NextSmoothImage.notifier(
              width: 64.w,
              height: 64.w,
              borderRadius: BorderRadius.circular(12),
              placeholder: Icon(Icons.music_note_rounded),
              notifier: coverNotifier,
              enableGestureDetection: true,
              onClicked: () {
                GetIt.instance.get<DesktopPlayingPageController>().show();
              },
            ),
          ).applyConstraint(
            id: coverId,
            top: parent.top,
            bottom: parent.bottom,
            left: parent.left,
            margin: EdgeInsets.only(left: 28.w),
          ),

          Container(
            height: 30.w,
            constraints: BoxConstraints(maxWidth: 240.w),
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              child: SmoothStreamBuilder(
                alignment: AlignmentDirectional.centerStart,
                stream: audioPlayerTranslator!.songStream(),
                builder: (context, songData) {
                  final song = songData.data;
                  final string = song != null ? song.name : "Nothing";
                  return OverflowWidgetWrapper.create(
                    child: Text(string, style: TextStyle(fontSize: 16.sp)),
                    maxWidth: double.infinity,
                    maxHeight: 30.w,
                  );
                },
              ),
            ),
          ).applyConstraint(
            id: nameId,
            top: coverId.top,
            left: coverId.right,
            margin: EdgeInsets.only(top: 2.w, left: 6),
          ),

          Container(
            width: 240.w,
            height: 30.w,
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              child: SmoothStreamBuilder(
                stream: audioPlayerTranslator!.songStream(),
                alignment: AlignmentDirectional.centerStart,
                builder: (context, songData) {
                  final song = songData.data;
                  final string = song != null ? song.buildArtists() : "Nothing";

                  return OverflowWidgetWrapper.create(
                    child: Text(
                      string,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: themeData().colorScheme.outline,
                      ),
                    ),
                    maxWidth: double.infinity,
                    maxHeight: 30.w,
                  );
                },
              ),
            ),
          ).applyConstraint(
            bottom: coverId.bottom,
            left: coverId.right,
            margin: EdgeInsets.only(bottom: 2.w, left: 6),
          ),

          SmoothLinearProgressIndicator(
            totalDurationStream: audioPlayerTranslator!.totalDurationStream(),
            currentDurationStream:
                audioPlayerTranslator!.audioPlayer.positionStream,
            onClick: (clickDuration) {
              audioPlayerTranslator!.audioPlayer.seek(clickDuration);
            },
          ).applyConstraint(
            bottom: parent.bottom,
            left: parent.left,
            right: parent.right,
            margin: EdgeInsets.only(bottom: (64.w + 56.h) / 12),
          ),

          SizedBox(
            width: 160 + 32 + 32,
            height: 64.w + 56.h,
            child: AudioOperator(
              audioPlayer: widget.audioPlayer,
              mode: AudioOperatorMode.desktop,
            ),
          ).applyConstraint(
            top: parent.top,
            bottom: parent.bottom,
            left: parent.left,
            right: parent.right,
          ),

          SizedBox(
            width: 240.w,
            height: 30.w,
            child: SmoothStreamBuilder(
              stream: Rx.combineLatest2(
                audioPlayerTranslator!.songStream(),
                audioPlayerTranslator!.songFileStream(),
                (song, songFile) => Pair(song, songFile),
              ),
              builder: (context, combinedData) {
                final pair = combinedData.data;
                if (pair == null || pair.key == null || pair.value == null) {
                  return SizedBox.shrink();
                }
                final song = pair.key;
                final songFile = pair.value;

                return SongChips(
                  song: song!,
                  songFile: songFile!,
                  reverse: true,
                );
              },
            ),
          ).applyConstraint(
            top: parent.top,
            bottom: parent.bottom,
            right: parent.right,
            margin: EdgeInsets.only(right: 28.w),
          ),
        ],
      ),
    );
  }
}
