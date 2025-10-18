import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';

abstract class AudioController {
  Future<void> init();

  Future<void> setAudioSources(List<AudioSource> sources);

  void addAudioSource(AudioSource source);

  void removeAudioSource(int songId);

  void insertAudioSource(int index, AudioSource source);

  void pause();

  Future<void> play();

  Future<void> seekTo(Duration position, {int? index});

  void stop();

  LoopMode getLoopMode();

  void setLoopMode(LoopMode mode);

  AudioPlayer getAudioPlayer();
}

class AudioControllerImpl implements AudioController {
  DartStrawberryServiceLogger? serviceLogger;
  AudioPlayer? audioPlayer;

  @override
  Future<void> init() async {
    if (audioPlayer != null) {
      return;
    }

    serviceLogger = GetIt.instance.get<DartStrawberryLogger>().openService(
      "PlayController",
    );
    audioPlayer = AudioPlayer();
    GetIt.instance.registerSingleton<AudioPlayer>(audioPlayer!);

    audioPlayer!.errorStream.listen((error) {
      serviceLogger!.error(
        "play error, index: ${error.index}: ${error.message}",
      );
      audioPlayer!.seekToNext().catchError((e) {
        serviceLogger!.error("seek next error: $e");
      });
    });
  }

  @override
  Future<Duration?> setAudioSources(List<AudioSource> sources) {
    serviceLogger!.trace("setting audio sources");
    return audioPlayer!.setAudioSources(sources);
  }

  @override
  void addAudioSource(AudioSource source) {
    serviceLogger!.trace("adding audio source: $source");
    audioPlayer!.addAudioSource(source);
  }

  @override
  void removeAudioSource(int songId) {
    serviceLogger!.trace("removing audio source, song id: $songId");

    final currentSequence = audioPlayer!.sequence;

    for (int i = 0; i < currentSequence.length; i++) {
      final source = currentSequence[i];
      if (source.tag != songId) {
        continue;
      }
      audioPlayer!.removeAudioSourceAt(i);
      return;
    }
  }

  @override
  void insertAudioSource(int index, AudioSource source) {
    serviceLogger!.trace(
      "inserting audio source, index: $index, source: $source",
    );

    audioPlayer!.insertAudioSource(index, source);
  }

  @override
  void pause() {
    serviceLogger!.trace("pausing");
    audioPlayer!.pause();
  }

  @override
  Future<void> play() {
    serviceLogger!.trace("playing");
    return audioPlayer!.play();
  }

  @override
  Future<void> seekTo(Duration position, {int? index}) {
    serviceLogger!.trace(
      "seeking, position: ${position.inMilliseconds}ms, index: $index",
    );
    return audioPlayer!.seek(position, index: index);
  }

  @override
  void stop() {
    serviceLogger!.trace("stopping");
    audioPlayer!.stop();
  }

  @override
  LoopMode getLoopMode() {
    return audioPlayer!.loopMode;
  }

  @override
  void setLoopMode(LoopMode mode) {
    serviceLogger!.trace("setting loop mode: $mode");
    audioPlayer!.setLoopMode(mode);
  }

  @override
  AudioPlayer getAudioPlayer() {
    return audioPlayer!;
  }
}
