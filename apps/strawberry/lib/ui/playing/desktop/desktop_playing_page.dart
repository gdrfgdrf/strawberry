import 'dart:async';
import 'dart:typed_data';

import 'package:domain/entity/song_entity.dart';
import 'package:fluid_background/fluid_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/play/audio_player_translator.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:widgets/widgets/next_smooth_image.dart';
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
            colorScheme.primary,
            colorScheme.primaryContainer,
            colorScheme.secondary,
            colorScheme.secondaryContainer,
            colorScheme.surface,
            colorScheme.secondaryContainer,
            colorScheme.tertiary,
            colorScheme.tertiaryContainer,
          ];
          fluidBackgroundController.mutateToColors(mutationColors);
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
    audioPlayerTranslator?.dispose();
    super.dispose();
  }

  Widget buildSongDisplay() {
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
            return Text(
              song.name,
              style: TextStyle(
                fontSize: 32.sp,
                shadows: [Shadow(blurRadius: 6)],
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
            return Text(
              song.buildArtists(),
              style: TextStyle(
                fontSize: 16.sp,
                shadows: [Shadow(blurRadius: 6)],
              ),
            );
          },
        ).applyConstraint(
          top: nameId.bottom,
          left: nameId.left,
          margin: EdgeInsets.only(top: 4, left: 4),
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
            child: buildSongDisplay(),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    final colorScheme = themeData().colorScheme;
    final initialColors = [
      colorScheme.primary,
      colorScheme.primaryContainer,
      colorScheme.secondary,
      colorScheme.secondaryContainer,
      colorScheme.surface,
      colorScheme.secondaryContainer,
      colorScheme.tertiary,
      colorScheme.tertiaryContainer,
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
