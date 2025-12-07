import 'dart:async';
import 'dart:typed_data';

import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_privilege_entity.dart';
import 'package:domain/entity/song_query_entity.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:strawberry/base/data_request_contracts.dart';

class RebornNetworkStreamAudioSource extends StreamAudioSource {
  final int songId;

  final DataRequestManager<SongQueryEntity> _songQueryManager;
  final DataRequestManager<Stream<List<int>>> _audioStreamManager;
  final DataRequestManager<Uint8List> _coverManager;
  final DataRequestManager<LyricsContainer> _lyricsManager;

  SongEntity? _song;
  SongPrivilegeEntity? _privilege;
  SongFileEntity? _songFile;
  Uint8List? _cover;
  LyricsContainer? _lyrics;
  WeakReference<List<int>>? _weakAudioData;
  Completer? _audioDataAwaitsCompleter;

  StreamController<Uint8List>? _currentStreamController;

  bool _disposed = false;
  bool _initialized = false;

  RebornNetworkStreamAudioSource(
    this.songId,
    this._songQueryManager,
    this._audioStreamManager,
    this._coverManager,
    this._lyricsManager,
  );

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    if (_disposed) {
      throw StateError("this audio source has been disposed");
    }
    _setupListeners();

    if (_weakAudioData == null || _weakAudioData?.target == null) {
      await _ensureAudioDataLoaded();
    }

    if (_weakAudioData == null || _weakAudioData?.target == null) {
      throw StateError("No audio data available");
    }

    return _createAudioResponse(_weakAudioData!.target!, start, end);
  }

  void _setupListeners() {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _songQueryManager.listen((event) async {
      if (event is RequestCompleted<SongQueryEntity>) {
        await _handleSongQueryResult(event.data);
      }
    });

    _audioStreamManager.listen((event) async {
      if (_audioDataAwaitsCompleter != null) {
        _audioDataAwaitsCompleter!.completeError(
          StateError("Updated audio stream has been executed"),
        );
        _audioDataAwaitsCompleter = null;
      }

      _audioDataAwaitsCompleter = Completer();
      if (event is RequestCompleted<Stream<List<int>>>) {
        await _handleAudioStreamResult(event.data);
        _audioDataAwaitsCompleter!.complete();
      } else {
        _audioDataAwaitsCompleter!.completeError(
          StateError("Request event error"),
        );
      }
    });

    _coverManager.listen((event) {
      if (event is RequestCompleted<Uint8List>) {
        _handleCoverResult(event.data);
      }
    });

    _lyricsManager.listen((event) {
      if (event is RequestCompleted<LyricsContainer>) {
        _handleLyricsResult(event.data);
      }
    });
  }

  Future<void> _handleSongQueryResult(SongQueryEntity query) async {
    for (final entry in query.map.entries) {
      final songOption = entry.key;
      final privilege = entry.value;

      if (songOption is IndependentNone<SongEntity>) {
        continue;
      }
      _song = (songOption as IndependentSome<SongEntity>).value;
      _privilege = privilege;

      await _triggerSubsequentRequests();
    }
  }

  Future<void> _triggerSubsequentRequests() async {
    if (_song == null || _privilege == null) {
      return;
    }
    await _audioStreamManager.execute();
    await _coverManager.execute();
    await _lyricsManager.execute();
  }

  Future<void> _handleAudioStreamResult(Stream<List<int>> stream) async {
    final completer = Completer<List<int>>();
    final chunks = <int>[];

    stream.listen(
      (chunk) => chunks.addAll(chunk),
      onDone: () {
        _weakAudioData = WeakReference(chunks);
        completer.complete(chunks);
      },
      onError: (e, s) {
        completer.completeError(e, s);
      },
    );

    await completer.future;
  }

  void _handleCoverResult(Uint8List cover) {
    _cover = cover;
  }

  void _handleLyricsResult(LyricsContainer lyrics) {
    _lyrics = lyrics;
  }

  Future<void> _ensureAudioDataLoaded() async {
    if (_weakAudioData != null && _weakAudioData!.target != null) {
      return;
    }
    _weakAudioData = null;

    if (_song == null || _privilege == null) {
      await _songQueryManager.execute();
    }

    if (_song != null && _privilege != null) {
      await _audioStreamManager.execute();
    } else {
      throw StateError("song and privilege are null");
    }

    bool shouldContinue = true;
    while (shouldContinue &&
        (_weakAudioData == null || _weakAudioData?.target == null)) {
      if (_audioDataAwaitsCompleter == null) {
        await Future.delayed(Duration.zero);
        continue;
      }

      await _audioDataAwaitsCompleter!.future.onError((e, s) {
        shouldContinue = false;
      });
    }

    if (_weakAudioData == null || _weakAudioData?.target == null) {
      throw StateError("No audio data available");
    }
  }

  StreamAudioResponse _createAudioResponse(
    List<int> audioData,
    int? start,
    int? end,
  ) {
    start ??= 0;
    end ??= audioData.length;

    if (start < 0) {
      start = 0;
    }
    if (end > audioData.length) {
      end = audioData.length;
    }
    if (start >= end) {
      throw RangeError('Invalid range: start=$start, end=$end');
    }

    final chunkSize = 1024 * 1024;
    final controller = StreamController<Uint8List>();

    controller.onListen = () async {
      try {
        var current = start!;

        while (current < end! && !controller.isClosed) {
          final chunkEnd =
              (current + chunkSize < end) ? current + chunkSize : end;

          final chunk = audioData.sublist(current, chunkEnd);
          controller.add(Uint8List.fromList(chunk));

          current = chunkEnd;

          await Future.delayed(Duration.zero);
        }

        if (!controller.isClosed) {
          await controller.close();
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
          await controller.close();
        }
      }
    };

    return StreamAudioResponse(
      sourceLength: audioData.length,
      contentLength: end - start,
      offset: start,
      stream: controller.stream,
      contentType: 'audio/mpeg',
    );
  }

  Future<void> reset() async {
    _weakAudioData = null;
    _song = null;
    _privilege = null;
    _songFile = null;
    _cover = null;
    _lyrics = null;

    await Future.wait([
      _songQueryManager.reset(),
      _audioStreamManager.reset(),
      _coverManager.reset(),
      _lyricsManager.reset(),
    ]);
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;

    if (_currentStreamController != null) {
      await _currentStreamController!.close();
    }

    await Future.wait([
      _songQueryManager.dispose(),
      _audioStreamManager.dispose(),
      _coverManager.dispose(),
      _lyricsManager.dispose(),
    ]);
  }
}
