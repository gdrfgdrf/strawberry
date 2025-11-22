import 'dart:async';

import 'package:domain/entity/song_entity.dart';
import 'package:domain/loved_playlist_ids_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:strawberry/bloc/song/like_song_event_state.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';
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
  List<StreamSubscription> subscriptions = [];
  SongBloc? songBloc = GetIt.instance.get();

  AudioPlayerTranslator? audioPlayerTranslator;

  AnimationController? playOperatorAnimationController;
  Animation<double>? playOperatorAnimation;

  StreamController<bool?>? songLikeStream = BehaviorSubject.seeded(null);

  @override
  void initState() {
    super.initState();
    audioPlayerTranslator = AudioPlayerTranslator(widget.audioPlayer);
    audioPlayerTranslator?.start();
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

    final songSubscription = audioPlayerTranslator!.songStream().listen((song) {
      if (song == null) {
        songLikeStream?.add(null);
        return;
      }

      final idsHolder = GetIt.instance.get<LovedPlaylistIdsHolder>();
      final id = song.id;
      songLikeStream?.add(idsHolder.exists(id));
    });
    subscriptions.add(songSubscription);

    final songBlocSubscription = songBloc!.stream.listen((state) {
      if (state is SongLoading) {
        songLikeStream?.add(null);
      }
      if (state is LikeSongFailure) {
        songLikeStream?.add(state.like);
      }
      if (state is LikeSongSuccess) {
        final idsHolder = GetIt.instance.get<LovedPlaylistIdsHolder>();
        if (state.like) {
          idsHolder.add(state.id);
        } else {
          idsHolder.remove(state.id);
        }

        songLikeStream?.add(state.like);
      }
    });
    subscriptions.add(songBlocSubscription);
  }

  @override
  void dispose() {
    songBloc?.close();
    songBloc = null;
    audioPlayerTranslator?.dispose();
    audioPlayerTranslator = null;
    playOperatorAnimationController?.dispose();
    playOperatorAnimationController = null;
    playOperatorAnimation = null;
    songLikeStream?.close();
    songLikeStream = null;
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
    super.dispose();
  }

  void toggleSongLike(bool like) {
    final latestSong = audioPlayerTranslator?.latestSong;
    if (latestSong == null) {
      return;
    }
    final id = latestSong.id;
    songBloc?.add(AttemptLikeSongEvent(id, like));
  }

  Widget buildFavorite() {
    return SmoothStreamBuilder(
      stream: Rx.combineLatest2(
        audioPlayerTranslator!.songStream(),
        songLikeStream!.stream,
        (a, b) => (a, b),
      ),
      builder: (context, combined) {
        if (!combined.hasData) {
          return SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(),
          );
        }

        final combination = combined.data as (SongEntity?, bool?);
        if (combination.$2 == null) {
          return SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(),
          );
        }

        final id = combination.$1?.id;
        if (id == null) {
          return IconButton(
            iconSize: 24,
            onPressed: null,
            icon: Icon(Icons.favorite_border_rounded),
          );
        }

        final idsHolder = GetIt.instance.get<LovedPlaylistIdsHolder>();
        final like = idsHolder.exists(id);

        if (like) {
          return IconButton(
            iconSize: 24,
            onPressed: () {
              toggleSongLike(false);
            },
            icon: Icon(Icons.favorite_rounded),
          );
        } else {
          return IconButton(
            iconSize: 24,
            onPressed: () {
              toggleSongLike(true);
            },
            icon: Icon(Icons.favorite_border_rounded),
          );
        }
      },
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
