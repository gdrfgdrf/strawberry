import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:strawberry/bloc/album/album_bloc.dart';
import 'package:strawberry/bloc/album/get_album_cover_event_state.dart';
import 'package:strawberry/play/audio_player_translator.dart';

class StrawberryAudioHandler extends BaseAudioHandler {
  List<StreamSubscription> subscriptions = <StreamSubscription>[];

  AudioPlayer? audioPlayer;
  AlbumBloc? albumBloc;
  AudioPlayerTranslator? translator;

  StrawberryAudioHandler();

  void init() {
    if (albumBloc != null) {
      albumBloc!.close();
      albumBloc = null;
    }
    if (translator != null) {
      translator!.dispose();
      translator = null;
    }
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
    subscriptions = [];

    audioPlayer = GetIt.instance.get();
    albumBloc = GetIt.instance.get();
    translator = AudioPlayerTranslator(audioPlayer!);
    translator!.start();

    final defaultPlaybackState = PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.pause,
        MediaControl.skipToNext,
      ],
      systemActions: {MediaAction.seek},
      processingState: AudioProcessingState.ready,
      playing: false,
      updatePosition: Duration.zero,
      bufferedPosition: Duration.zero,
    );
    playbackState.add(defaultPlaybackState);

    final playerStateSubscription = audioPlayer!.playerStateStream.listen((
      playerState,
    ) {
      ProcessingState processingState = playerState.processingState;
      AudioProcessingState translatedState;
      switch (processingState) {
        case ProcessingState.idle:
          {
            translatedState = AudioProcessingState.idle;
          }
        case ProcessingState.loading:
          {
            translatedState = AudioProcessingState.loading;
          }
        case ProcessingState.buffering:
          {
            translatedState = AudioProcessingState.buffering;
          }
        case ProcessingState.ready:
          {
            translatedState = AudioProcessingState.ready;
          }
        case ProcessingState.completed:
          {
            translatedState = AudioProcessingState.completed;
          }
      }
      PlaybackState? currentPlaybackState = playbackState.valueOrNull?.copyWith(
        playing: playerState.playing,
        processingState: translatedState,
      );
      currentPlaybackState ??= defaultPlaybackState.copyWith(
        playing: playerState.playing,
        processingState: translatedState,
      );

      playbackState.add(currentPlaybackState);
    });
    subscriptions.add(playerStateSubscription);

    final bufferedPositionSubscription = audioPlayer!.bufferedPositionStream
        .listen((bufferedPosition) {
          PlaybackState? currentPlaybackState = playbackState.valueOrNull
              ?.copyWith(bufferedPosition: bufferedPosition);
          currentPlaybackState ??= defaultPlaybackState.copyWith(
            bufferedPosition: bufferedPosition,
          );

          playbackState.add(currentPlaybackState);
        });
    subscriptions.add(bufferedPositionSubscription);

    final positionSubscription = audioPlayer!.positionStream.listen((position) {
      PlaybackState? currentPlaybackState = playbackState.valueOrNull?.copyWith(
        updatePosition: position,
      );
      currentPlaybackState ??= defaultPlaybackState.copyWith(
        updatePosition: position,
      );

      playbackState.add(currentPlaybackState);
    });
    subscriptions.add(positionSubscription);

    final songSubscription = translator!.songStream().listen((song) {
      MediaItem mediaItem = MediaItem(id: "Nothing", title: "Nothing");
      if (song != null) {
        mediaItem = MediaItem(
          id: song.id.toString(),
          title: song.name,
          artist: song.buildArtists(),
          album: song.basicAlbum?.name,
          duration: song.duration,
        );
      }
      this.mediaItem.add(mediaItem);
    });
    subscriptions.add(songSubscription);

    final coverSubscription = translator!.coverStream().listen((_) {
      final song = translator?.latestSong;
      if (song == null) {
        return;
      }
      final albumId = song.compatibleAlbumId();
      final url = song.basicAlbum?.picUrl;
      if (url == null) {
        return;
      }

      albumBloc!.add(
        AttemptGetAlbumCoverPathEvent(albumId, url, (data) {
          data.fold((failure) {}, (path) {
            final latestSongId = translator?.latestSong?.id;
            if (latestSongId != null && song.id == latestSongId) {
              final mediaItem =
                  this.mediaItem.valueOrNull ??
                  MediaItem(
                    id: song.id.toString(),
                    title: song.name,
                    artist: song.buildArtists(),
                    album: song.basicAlbum?.name,
                    duration: song.duration,
                  );
              final artMediaItem = mediaItem.copyWith(
                artUri: Uri.parse("file://$path"),
              );
              this.mediaItem.add(artMediaItem);
            }
          });
        }),
      );
    });
    subscriptions.add(coverSubscription);
  }

  @override
  Future<void> play() {
    return audioPlayer!.play();
  }

  @override
  Future<void> pause() {
    return audioPlayer!.pause();
  }

  @override
  Future<void> seek(Duration position) {
    return audioPlayer!.seek(position);
  }

  @override
  Future<void> skipToPrevious() {
    return audioPlayer!.seekToPrevious();
  }

  @override
  Future<void> skipToNext() {
    return audioPlayer!.seekToNext();
  }

  @override
  Future<void> skipToQueueItem(int index) {
    return audioPlayer!.seek(Duration.zero, index: index);
  }

  @override
  Future<void> stop() {
    albumBloc?.close();
    albumBloc = null;
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    translator?.dispose();
    translator = null;
    return audioPlayer?.stop() ?? Future.value();
  }

  static void prepareSingleton() {
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isLinux) {
      return;
    }
    if (!GetIt.instance.isRegistered<BaseAudioHandler>()) {
      final audioHandler = StrawberryAudioHandler();
      GetIt.instance.registerSingleton<BaseAudioHandler>(audioHandler);
    }
  }
}
