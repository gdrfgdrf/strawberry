import 'dart:async';

import 'package:domain/entity/song_quality_entity.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/files.dart';
import 'package:strawberry/bloc/album/album_bloc.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';
import 'package:strawberry/bloc/user/user_bloc.dart';
import 'package:strawberry/bloc/user/user_habit_event_state.dart';

import 'network_stream_audio_source.dart';

class PlaylistUnit {
  final int songId;
  final SongQualityLevel? level;

  const PlaylistUnit(this.songId, this.level);
}

abstract class PlaylistManager {
  StreamSubscription<List<int>?> subscribeAudioSources(
    void Function(List<int>?) listener,
  );

  Future<void> replace(String sha256, List<PlaylistUnit> list);

  Future<void> seekAt(int index);

  Future<void> playAt(int index);

  String? getCurrentSha256();

  void setCurrentSha256(String sha256);

  LoopMode getLoopMode();

  void setLoopMode(LoopMode mode);
}

class PlaylistManagerImpl extends PlaylistManager {
  DartStrawberryServiceLogger? serviceLogger;
  final UserBloc userBloc = GetIt.instance.get();
  final SongBloc songBloc = GetIt.instance.get();
  final AlbumBloc albumBloc = GetIt.instance.get();
  final AudioPlayer audioPlayer = GetIt.instance.get();
  final StreamController<List<int>?> audioSourcesStream =
      BehaviorSubject.seeded(null);

  String? currentSha256;

  String? restoreTempSha256;
  String? restoreTempIds;
  String? restoreTempIndex;

  PlaylistManagerImpl() {
    serviceLogger = GetIt.instance.get<DartStrawberryLogger>().openService(
      "PlaylistManager",
    );

    userBloc.add(AttemptGetUserHabitEvent("song-list-sha256"));
    userBloc.add(AttemptGetUserHabitEvent("song-list-ids"));
    userBloc.add(AttemptGetUserHabitEvent("song-list-index"));

    audioPlayer.currentIndexStream.listen((index) {
      userBloc.add(
        AttemptStoreUserHabitEvent("song-list-index", index?.toString()),
      );
    });
    userBloc.stream.listen((state) {
      if (state is GetUserHabitSuccess) {
        final key = state.key;
        final value = state.value;
        if (value == null) {
          return;
        }

        if (key == "song-list-sha256") {
          restoreTempSha256 = value;
          restoreSongList();
        }
        if (key == "song-list-ids") {
          restoreTempIds = value;
          restoreSongList();
        }
        if (key == "song-list-index") {
          restoreTempIndex = value;
          restoreSongList();
        }
      }
    });
  }

  void restoreSongList() async {
    if (restoreTempSha256 == null ||
        restoreTempIds == null ||
        restoreTempIndex == null) {
      return;
    }
    final index = int.tryParse(restoreTempIndex!);
    restoreTempIndex = null;
    if (index == null) {
      return;
    }

    final calculatedSha256 = await Files.sha256(restoreTempIds!.codeUnits);
    if (calculatedSha256 != restoreTempSha256) {
      restoreTempSha256 = null;
      restoreTempIds = null;
      return;
    }

    final ids =
        restoreTempIds!.split(",").map((id) => int.tryParse(id)).toList();

    final units = <PlaylistUnit>[];
    for (final id in ids) {
      if (id == null) {
        restoreTempSha256 = null;
        restoreTempIds = null;
        return;
      }
      final unit = PlaylistUnit(id, null);
      units.add(unit);
    }

    await replace(restoreTempSha256!, units);
    await seekAt(index);
    restoreTempSha256 = null;
    restoreTempIds = null;
    restoreTempIndex = null;
  }

  @override
  StreamSubscription<List<int>?> subscribeAudioSources(
    void Function(List<int>? p1) listener,
  ) {
    return audioSourcesStream.stream.listen(listener);
  }

  @override
  Future<void> replace(String sha256, List<PlaylistUnit> list) async {
    serviceLogger!.trace("replacing playlist");

    final oldSources = audioPlayer.audioSources;
    for (final oldSource in oldSources) {
      if (oldSource is! NetworkStreamAudioSource) {
        continue;
      }
      oldSource.dispose();
    }

    final sources =
        list
            .map(
              (unit) =>
                  NetworkStreamAudioSource(unit.songId, songBloc, albumBloc),
            )
            .toList();
    await audioPlayer.setAudioSources(sources);
    currentSha256 = sha256;

    audioSourcesStream.add(list.map((unit) => unit.songId).toList());
  }

  @override
  Future<void> seekAt(int index) async {
    serviceLogger!.trace("seek at $index");

    await audioPlayer.seek(Duration.zero, index: index);
  }

  @override
  Future<void> playAt(int index) async {
    serviceLogger!.trace("play at $index");

    await audioPlayer.seek(Duration.zero, index: index);
    await audioPlayer.play();
  }

  @override
  String? getCurrentSha256() {
    return currentSha256;
  }

  @override
  void setCurrentSha256(String sha256) {
    currentSha256 = sha256;
  }

  @override
  LoopMode getLoopMode() {
    return audioPlayer.loopMode;
  }

  @override
  void setLoopMode(LoopMode mode) {
    serviceLogger!.trace("setting loop mode: $mode");
    audioPlayer.setLoopMode(mode);
  }
}
