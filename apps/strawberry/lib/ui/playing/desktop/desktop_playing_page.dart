import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:domain/entity/song_entity.dart';
import 'package:fluid_background/fluid_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_scheduler.dart';
import 'package:shared/platform_extension.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/play/audio_player_translator.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:widgets/widgets/next_smooth_image.dart';
import 'package:widgets/widgets/scrollable_lyrics.dart';
import 'package:widgets/widgets/smooth_lyrics.dart';
import 'package:widgets/widgets/smooth_stream_builder.dart';

class DesktopPlayingPage extends AbstractUiWidget {
  final AudioPlayer audioPlayer;

  const DesktopPlayingPage({super.key, required this.audioPlayer});

  @override
  State<StatefulWidget> createState() => _PlayingPageState();
}

class _PlayingPageState
    extends AbstractUiWidgetState<DesktopPlayingPage, EmptyDelegate> {
  final FluidBackgroundController fluidBackgroundController =
      FluidBackgroundController();

  final List<StreamSubscription> subscriptions = [];
  AudioPlayerTranslator? audioPlayerTranslator;
  LyricScheduler? lyricScheduler;

  BehaviorSubject<ColorScheme?>? colorSchemeStream = BehaviorSubject.seeded(
    null,
  );

  @override
  EmptyDelegate createDelegate() {
    return EmptyDelegate();
  }

  @override
  List<VoidCallback> postListeners() {
    return [
      () {
        audioPlayerTranslator!.start();
        final coverSubscription = audioPlayerTranslator!.coverStream().listen((
          bytes,
        ) async {
          if (bytes == null) {
            return;
          }

          final colorScheme = await ColorScheme.fromImageProvider(
            provider: MemoryImage(Uint8List.fromList(bytes)),
          );

          final mutationColors = [
            colorScheme.primary.withAlpha(160),
            colorScheme.primaryContainer.withAlpha(160),
            colorScheme.secondary.withAlpha(160),
            colorScheme.secondaryContainer.withAlpha(160),
            colorScheme.surface.withAlpha(160),
            colorScheme.secondaryContainer.withAlpha(160),
            colorScheme.tertiary.withAlpha(160),
            colorScheme.tertiaryContainer.withAlpha(160),
          ];
          fluidBackgroundController.mutateToColors(mutationColors);

          final lastColorScheme = colorSchemeStream?.valueOrNull;
          if (lastColorScheme != null && lastColorScheme == colorScheme) {
            return;
          }
          colorSchemeStream?.add(colorScheme);
        });
        subscriptions.add(coverSubscription);
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    audioPlayerTranslator = AudioPlayerTranslator(widget.audioPlayer);
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
    audioPlayerTranslator?.dispose();
    audioPlayerTranslator = null;
    lyricScheduler?.dispose();
    lyricScheduler = null;
    colorSchemeStream?.close();
    colorSchemeStream = null;
    super.dispose();
  }

  Widget buildDisplayV2() {
    final screenSize = MediaQuery.of(context).size;
    final coverId = ConstraintId("cover");
    final nameId = ConstraintId("name");

    return ConstraintLayout(
      children: [
        SmoothClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            child: NextSmoothImage.bytesStream(
              stream: audioPlayerTranslator!.coverStream(),
              width: 128.w,
              height: 128.w,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ).applyConstraint(
          id: coverId,
          top: parent.top,
          left: parent.left,
          margin: EdgeInsets.only(top: 24, left: 24),
        ),

        SmoothStreamBuilder(
          stream: audioPlayerTranslator!.songStream(),
          alignment: AlignmentDirectional.centerStart,
          builder: (context, songData) {
            if (!songData.hasData) {
              return SizedBox.shrink();
            }
            final song = songData.data as SongEntity;
            return SizedBox(
              width: screenSize.width / 4,
              child: Text(
                song.name,
                softWrap: true,
                style: TextStyle(
                  fontSize: 24.sp,
                  shadows: [Shadow(blurRadius: 6)],
                ),
              ),
            );
          },
        ).applyConstraint(
          id: nameId,
          top: coverId.top,
          left: coverId.right,
          margin: EdgeInsets.only(top: 2, left: 6),
        ),

        SmoothStreamBuilder(
          stream: audioPlayerTranslator!.songStream(),
          alignment: AlignmentDirectional.centerStart,
          builder: (context, songData) {
            if (!songData.hasData) {
              return SizedBox.shrink();
            }
            final song = songData.data as SongEntity;
            return SizedBox(
              width: screenSize.width / 4.5,
              child: Text(
                song.buildArtists(),
                softWrap: true,
                style: TextStyle(
                  fontSize: 16.sp,
                  shadows: [Shadow(blurRadius: 6)],
                ),
              ),
            );
          },
        ).applyConstraint(
          top: nameId.bottom,
          left: coverId.right,
          margin: EdgeInsets.only(left: 6),
        ),

        SmoothLyrics(
          width: screenSize.width,
          height: screenSize.height,
          lyricDisplay: LyricDisplay.center,
          lyricWidth: screenSize.width - 2 * (screenSize.width / 6),
          lyricsStream: audioPlayerTranslator!.lyricsStream(),
          positionStream: audioPlayerTranslator!.audioPlayer.positionStream,
          colorSchemeStream: colorSchemeStream,
          onClicked: (index, lyric) {
            audioPlayerTranslator!.audioPlayer.seek(lyric.position);
          },
        ).applyConstraint(
          top: parent.top,
          bottom: parent.bottom,
          left: parent.left,
          right: parent.right,
        ),
      ],
    );
  }

  Widget buildDisplay() {
    final screenSize = MediaQuery.of(context).size;
    final coverId = ConstraintId("cover");
    final nameId = ConstraintId("name");

    return ConstraintLayout(
      children: [
        SmoothClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            child: NextSmoothImage.bytesStream(
              stream: audioPlayerTranslator!.coverStream(),
              width: 256.w,
              height: 256.w,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ).applyConstraint(
          id: coverId,
          top: parent.top,
          left: parent.left,
          margin: EdgeInsets.only(
            top: (screenSize.height / 3) - 256.w / 2,
            left: (screenSize.width / 6) - 256.w / 2,
          ),
        ),

        SmoothStreamBuilder(
          stream: audioPlayerTranslator!.songStream(),
          alignment: AlignmentDirectional.centerStart,
          builder: (context, songData) {
            if (!songData.hasData) {
              return SizedBox.shrink();
            }
            final song = songData.data as SongEntity;
            return SizedBox(
              width: screenSize.width / 2.6,
              child: Text(
                song.name,
                softWrap: true,
                style: TextStyle(
                  fontSize: 32.sp,
                  shadows: [Shadow(blurRadius: 6)],
                ),
              ),
            );
          },
        ).applyConstraint(
          id: nameId,
          top: coverId.bottom,
          left: coverId.left,
          margin: EdgeInsets.only(top: 4, left: 4),
        ),

        SmoothStreamBuilder(
          stream: audioPlayerTranslator!.songStream(),
          alignment: AlignmentDirectional.centerStart,
          builder: (context, songData) {
            if (!songData.hasData) {
              return SizedBox.shrink();
            }
            final song = songData.data as SongEntity;
            return SizedBox(
              width: screenSize.width / 3,
              child: Text(
                song.buildArtists(),
                softWrap: true,
                style: TextStyle(
                  fontSize: 16.sp,
                  shadows: [Shadow(blurRadius: 6)],
                ),
              ),
            );
          },
        ).applyConstraint(
          top: nameId.bottom,
          left: nameId.left,
          margin: EdgeInsets.only(top: 4, left: 4),
        ),

        SmoothLyrics(
          lyricWidth:
              screenSize.width -
              ((screenSize.height / 3) - 256.w / 2 + 256.w) -
              screenSize.width / 3,
          lyricsStream: audioPlayerTranslator!.lyricsStream(),
          positionStream: audioPlayerTranslator!.audioPlayer.positionStream,
          colorSchemeStream: colorSchemeStream,
          onClicked: (index, lyric) {
            audioPlayerTranslator!.audioPlayer.seek(lyric.position);
          },
        ).applyConstraint(
          top: parent.top,
          bottom: parent.bottom,
          left: coverId.right,
          margin: EdgeInsets.only(left: screenSize.width / 3),
        ),
      ],
    );
  }

  Widget buildForeground() {
    final screenSize = MediaQuery.of(context).size;

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SmoothContainer(
            height: screenSize.height,
            child: buildDisplayV2(),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    final colorScheme = themeData().colorScheme;
    final initialColors = [
      colorScheme.primary.withAlpha(160),
      colorScheme.primaryContainer.withAlpha(160),
      colorScheme.secondary.withAlpha(160),
      colorScheme.secondaryContainer.withAlpha(160),
      colorScheme.surface.withAlpha(160),
      colorScheme.secondaryContainer.withAlpha(160),
      colorScheme.tertiary.withAlpha(160),
      colorScheme.tertiaryContainer.withAlpha(160),
    ];

    return FluidBackground(
      controller: fluidBackgroundController,
      initialPositions: InitialOffsets.random(initialColors.length),
      initialColors: InitialColors.custom(initialColors),
      allowColorChanging: true,
      bubbleMutationDuration: Duration(seconds: 4),
      sizeChangingRange: [300, 600],
      child: buildForeground(),
    );
  }
}
