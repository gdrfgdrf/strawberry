import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:natives/ffi/smtc.dart';
import 'package:strawberry/bloc/album/album_bloc.dart';
import 'package:strawberry/bloc/album/get_album_cover_event_state.dart';
import 'package:strawberry/play/audio_player_translator.dart';

enum ControlEvent { play, pause, previous, next, unknown }

abstract class PlatformSpecificController {
  void prepare();

  static PlatformSpecificController? auto() {
    if (Platform.isWindows) {
      return windows();
    }
    return null;
  }

  static PlatformSpecificController windows() {
    return _WindowsController();
  }
}

class _WindowsController extends PlatformSpecificController {
  @override
  void prepare() {
    final audioPlayer = GetIt.instance.get<AudioPlayer>();
    final translator = AudioPlayerTranslator(audioPlayer);
    final albumBloc = GetIt.instance.get<AlbumBloc>();
    translator.start();

    final smtc = SmtcFlutter();
    smtc.subscribeToControlEvents().listen((event) {
      switch (event) {
        case 0:
          {
            audioPlayer.play();
          }
        case 1:
          {
            audioPlayer.pause();
          }
        case 2:
          {
            audioPlayer.seekToNext();
          }
        case 3:
          {
            audioPlayer.seekToPrevious();
          }
        default:
          {}
      }
    });

    translator.songStream().listen((song) {
      if (song == null) {
        smtc.updateDisplay(
          title: "Nothing",
          artist: "Nothing",
          album: "Nothing",
        );
        return;
      }

      final albumId = song.compatibleAlbumId();
      final url = song.basicAlbum?.picUrl;
      if (url == null) {
        return;
      }

      albumBloc.add(
        AttemptGetAlbumCoverPathEvent(albumId, url, (data) {
          data.fold(
            (failure) {
              smtc.updateDisplay(
                title: song.name,
                artist: song.buildArtists(),
                album: song.basicAlbum?.name ?? "",
              );
            },
            (path) {
              final latestSongId = translator.latestSong?.id;
              if (song.id == latestSongId) {
                smtc.updateDisplay(
                  title: song.name,
                  artist: song.buildArtists(),
                  album: song.basicAlbum?.name ?? "",
                  path: path.replaceAll("/", "\\"),
                );
              }
            },
          );
        }),
      );
    });

    audioPlayer.playingStream.listen((playing) {
      smtc.updateState(state: playing ? SMTCState.playing : SMTCState.paused);
    });
  }
}
