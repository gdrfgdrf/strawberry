import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dartz/dartz.dart';
import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_query_entity.dart';
import 'package:domain/result/result.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:strawberry/bloc/album/album_bloc.dart';
import 'package:strawberry/bloc/song/query_song_event_state.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';

abstract class DefaultAudioHandler extends BaseAudioHandler {
  AudioPlayer audioPlayer;

  DefaultAudioHandler(this.audioPlayer);
}

class DefaultAudioHandlerImpl extends DefaultAudioHandler with SeekHandler {
  DefaultAudioHandlerImpl(super.audioPlayer);

  @override
  Future<void> prepare() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    audioPlayer.playbackEventStream.listen(_broadcastState);
  }

  @override
  Future<void> play() => audioPlayer.play();

  @override
  Future<void> pause() => audioPlayer.pause();

  @override
  Future<void> seek(Duration position) => audioPlayer.seek(position);

  @override
  Future<void> skipToNext() async {
    audioPlayer.seekToNext();

    // final currentSequence = audioPlayer.sequence;
    // final currentIndex = audioPlayer.currentIndex;
    // if (currentIndex == null) {
    //   return;
    // }
    //
    // final source = currentSequence[currentIndex];
    // final id = source.tag;
    // currentSongId = id;
    // songBloc.add(AttemptQuerySongEvent([id], songQueryReceiver));
  }

  @override
  Future<void> skipToPrevious() async {
    audioPlayer.seekToPrevious();

    final currentSequence = audioPlayer.sequence;
    // final currentIndex = audioPlayer.currentIndex;
    // if (currentIndex == null) {
    //   return;
    // }
    //
    // final source = currentSequence[currentIndex];
    // final id = source.tag;
    // currentSongId = id;
    // songBloc.add(AttemptQuerySongEvent([id], songQueryReceiver));
  }

  @override
  Future<void> setSpeed(double speed) => audioPlayer.setSpeed(speed);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        {
          audioPlayer.setLoopMode(LoopMode.off);
        }
      case AudioServiceRepeatMode.one:
        {
          audioPlayer.setLoopMode(LoopMode.one);
        }
      case AudioServiceRepeatMode.all:
        {
          audioPlayer.setLoopMode(LoopMode.all);
        }
      default:
        {}
    }
  }

  @override
  Future<void> stop() async {
    await audioPlayer.stop();
    await super.stop();
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = audioPlayer.playing;
    final processingState = _getProcessingState(event.processingState);

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: [0, 1, 3],
        processingState: processingState,
        playing: playing,
        updatePosition: audioPlayer.position,
        bufferedPosition: audioPlayer.bufferedPosition,
        speed: audioPlayer.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  AudioProcessingState _getProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }
}
