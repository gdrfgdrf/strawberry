import 'package:domain/entity/song_quality_entity.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:strawberry/bloc/album/album_bloc.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';
import 'package:strawberry/play/audio_controller.dart';
import 'package:uuid/uuid.dart';

import 'network_stream_audio_source.dart';

class PlaylistUnit {
  final int songId;
  final SongQualityLevel? level;

  const PlaylistUnit(this.songId, this.level);
}

abstract class PlaylistManager {
  void add(PlaylistUnit unit);

  void remove(int songId);

  Future<String> replace(List<PlaylistUnit> list);

  Future<void> playAt(int index);

  String? getCurrentPlaylistUuid();

  LoopMode getLoopMode();

  void setLoopMode(LoopMode mode);

  AudioPlayer getAudioPlayer();
}

class PlaylistManagerImpl extends PlaylistManager {
  DartStrawberryServiceLogger? serviceLogger;
  final SongBloc songBloc = GetIt.instance.get();
  final AlbumBloc albumBloc = GetIt.instance.get();
  final AudioController playController = GetIt.instance.get();

  String? currentPlaylistUuid;

  PlaylistManagerImpl() {
    serviceLogger = GetIt.instance.get<DartStrawberryLogger>().openService(
      "PlaylistManager",
    );
  }

  @override
  void add(PlaylistUnit unit) {
    serviceLogger!.trace(
      "adding unit, song id: ${unit.songId}, level: ${unit.level}",
    );

    final source = NetworkStreamAudioSource(unit.songId, songBloc, albumBloc);
    playController.addAudioSource(source);
    currentPlaylistUuid = null;
  }

  @override
  void remove(int songId) {
    serviceLogger!.trace("removing song, id: $songId");

    playController.removeAudioSource(songId);
    currentPlaylistUuid = null;
  }

  @override
  Future<String> replace(List<PlaylistUnit> list) async {
    serviceLogger!.trace("replacing playlist");

    final oldSources = playController.getAudioPlayer().audioSources;
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
    await playController.setAudioSources(sources);
    currentPlaylistUuid = Uuid().v4();
    return currentPlaylistUuid!;
  }

  @override
  Future<void> playAt(int index) async {
    serviceLogger!.trace("play at $index");

    await playController.seekTo(Duration.zero, index: index);
    await playController.play();
  }

  @override
  String? getCurrentPlaylistUuid() {
    return currentPlaylistUuid;
  }

  @override
  LoopMode getLoopMode() {
    return playController.getLoopMode();
  }

  @override
  void setLoopMode(LoopMode mode) {
    serviceLogger!.trace("setting loop mode: $mode");
    playController.setLoopMode(mode);
  }

  @override
  AudioPlayer getAudioPlayer() {
    return playController.getAudioPlayer();
  }
}
