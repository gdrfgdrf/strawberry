import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:just_audio/just_audio.dart';
import 'package:widgets/widgets/smooth_stream_builder.dart';

import '../audio_player_translator.dart';

enum AudioOperatorMode { desktop, mobile }

class AudioOperator extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final AudioOperatorMode mode;

  const AudioOperator({
    super.key,
    required this.audioPlayer,
    required this.mode,
  });

  @override
  State<StatefulWidget> createState() => _AudioOperatorState();
}

class _AudioOperatorState extends State<AudioOperator>
    with TickerProviderStateMixin {
  AudioPlayerTranslator? audioPlayerTranslator;

  AnimationController? playOperatorAnimationController;
  Animation<double>? playOperatorAnimation;

  @override
  void initState() {
    super.initState();
    audioPlayerTranslator = AudioPlayerTranslator(widget.audioPlayer);
    playOperatorAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    playOperatorAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: playOperatorAnimationController!,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    audioPlayerTranslator?.dispose();
    playOperatorAnimationController?.dispose();
    playOperatorAnimation = null;
    super.dispose();
  }

  Widget buildFavorite() {
    return IconButton(
      iconSize: 24,
      onPressed: () {},
      icon: Icon(Icons.favorite_border_rounded),
    );
  }

  Widget buildPrevious() {
    return SmoothStreamBuilder(
      stream: audioPlayerTranslator!.audioPlayer.playerStateStream,
      builder: (context, _) {
        void Function()? seekToPrevious = () {
          audioPlayerTranslator!.audioPlayer.seekToPrevious();
        };
        if (!audioPlayerTranslator!.audioPlayer.hasPrevious) {
          seekToPrevious = null;
        }

        return IconButton(
          iconSize: 32,
          onPressed: seekToPrevious,
          icon: Icon(Icons.skip_previous_rounded),
        );
      },
    );
  }

  Widget buildPlay() {
    return SmoothStreamBuilder(
      stream: audioPlayerTranslator!.audioPlayer.playingStream,
      builder: (context, playingData) {
        final playing = playingData.data;
        if (playingData.connectionState != ConnectionState.done) {
          if (playing == true) {
            playOperatorAnimationController!.forward();
          } else {
            playOperatorAnimationController!.reverse();
          }
        }

        return SmoothStreamBuilder(
          stream: audioPlayerTranslator!.audioPlayer.processingStateStream,
          builder: (context, processingStateData) {
            final state = processingStateData.data;

            final isIdle = state == ProcessingState.idle;
            void Function()? onPressed = () {
              if (playing == true) {
                audioPlayerTranslator!.audioPlayer.pause();
              } else {
                audioPlayerTranslator!.audioPlayer.play();
              }
            };
            if (isIdle) {
              onPressed = null;
            }

            return IconButton(
              iconSize: 32,
              onPressed: onPressed,
              icon: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: playOperatorAnimation!,
              ),
            );
          },
        );
      },
    );
  }

  Widget buildNext() {
    return SmoothStreamBuilder(
      stream: audioPlayerTranslator!.audioPlayer.playerStateStream,
      builder: (context, _) {
        void Function()? seekToNext = () {
          audioPlayerTranslator!.audioPlayer.seekToNext();
        };
        if (!audioPlayerTranslator!.audioPlayer.hasNext) {
          seekToNext = null;
        }

        return IconButton(
          iconSize: 36,
          onPressed: seekToNext,
          icon: Icon(Icons.skip_next_rounded),
        );
      },
    );
  }

  Widget buildShuffle() {
    return IconButton(
      iconSize: 24,
      onPressed: () {},
      icon: Icon(Icons.repeat_rounded),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == AudioOperatorMode.desktop) {
      return ConstraintLayout(
        children: [
          buildFavorite().applyConstraint(
            top: parent.top,
            bottom: parent.bottom,
            left: parent.left,
          ),

          buildPrevious().applyConstraint(
            top: parent.top,
            bottom: parent.bottom,
            left: parent.left,
            margin: EdgeInsets.only(left: 48),
          ),

          buildPlay().applyConstraint(
            top: parent.top,
            bottom: parent.bottom,
            left: parent.left,
            right: parent.right,
          ),

          buildNext().applyConstraint(
            top: parent.top,
            bottom: parent.bottom,
            right: parent.right,
            margin: EdgeInsets.only(right: 48),
          ),

          buildShuffle().applyConstraint(
            top: parent.top,
            bottom: parent.bottom,
            right: parent.right,
          ),
        ],
      );
    }

    return ConstraintLayout(
      children: [
        buildPlay().applyConstraint(
          top: parent.top,
          bottom: parent.bottom,
          left: parent.left,
          right: parent.right,
        ),
      ],
    );
  }
}
