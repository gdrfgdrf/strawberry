
import 'dart:async';

import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_privilege_entity.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:uuid/v4.dart';

import 'network_stream_audio_source.dart';

class AudioPlayerTranslator {
  final AudioPlayer audioPlayer;

  String? id;
  void Function()? canceler;

  final BehaviorSubject<List<int>?> coverController = BehaviorSubject.seeded(
    null,
  );
  final BehaviorSubject<SongEntity?> songController = BehaviorSubject.seeded(
    null,
  );
  final BehaviorSubject<SongPrivilegeEntity?> privilegeController =
  BehaviorSubject.seeded(null);
  final BehaviorSubject<SongFileEntity?> songFileController =
  BehaviorSubject.seeded(null);
  final BehaviorSubject<LyricsContainer?> lyricsController = BehaviorSubject.seeded(null);

  final BehaviorSubject<Duration?> totalDurationController =
  BehaviorSubject.seeded(null);

  StreamSubscription<int?>? currentIndexSubscription;
  int? latestIndex;
  SongEntity? latestSong;

  AudioPlayerTranslator(this.audioPlayer);

  Stream<List<int>?> coverStream() {
    return coverController.stream;
  }

  Stream<SongEntity?> songStream() {
    return songController.stream;
  }

  Stream<SongPrivilegeEntity?> privilegeStream() {
    return privilegeController.stream;
  }

  Stream<SongFileEntity?> songFileStream() {
    return songFileController.stream;
  }

  Stream<LyricsContainer?> lyricsStream() {
    return lyricsController.stream;
  }

  Stream<Duration?> totalDurationStream() {
    return totalDurationController.stream;
  }

  void start() {
    id = UuidV4().generate();
    currentIndexSubscription = audioPlayer.currentIndexStream.listen((index) {
      if (songController.isClosed || privilegeController.isClosed) {
        return;
      }
      if (index == null) {
        addNull();
        return;
      }

      final audioSource = audioPlayer.audioSources.elementAtOrNull(index);
      if (audioSource == null || audioSource is! NetworkStreamAudioSource) {
        addNull();
        return;
      }

      /// currentIndexStream 这玩意会一直推送，不管有没有变化
      if (latestIndex == index) {
        return;
      }

      latestIndex = index;
      canceler = audioSource.followRequest(
        id: id!,
        onCover: (bytes) {
          if (latestIndex == index) {
            coverController.add(bytes);
          }
        },
        onSong: (song) {
          if (latestIndex == index) {
            latestSong = song;
            songController.add(song);
            totalDurationController.add(song?.duration);
          }
        },
        onSongPrivilege: (privilege) {
          if (latestIndex == index) {
            privilegeController.add(privilege);
          }
        },
        onSongFile: (songFile) {
          if (latestIndex == index) {
            songFileController.add(songFile);
          }
        },
        onLyrics: (lyrics) {
          if (latestIndex == index) {
            lyricsController.add(lyrics);
          }
        }
      );

    });
  }

  void addNull() {
    coverController.add(null);
    songController.add(null);
    privilegeController.add(null);
    songFileController.add(null);
    lyricsController.add(null);
    totalDurationController.add(null);
  }

  void dispose() {
    canceler?.call();
    currentIndexSubscription?.cancel();
    coverController.close();
    songController.close();
    privilegeController.close();
    songFileController.close();
    lyricsController.close();
    totalDurationController.close();
  }
}