import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_privilege_entity.dart';
import 'package:domain/entity/song_query_entity.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pair/pair.dart';
import 'package:shared/lyric/lyric_parser.dart';
import 'package:strawberry/bloc/album/album_bloc.dart';
import 'package:strawberry/bloc/song/download_player_song_files_event_state.dart';
import 'package:strawberry/bloc/song/get_song_lyrics_event_state.dart';
import 'package:strawberry/bloc/song/query_song_event_state.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';
import 'package:strawberry/ui/list/cover_request.dart';

import '../bloc/album/get_album_cover_event_state.dart';

class _InternalRequest<T> {
  StreamController<T?>? controller = StreamController.broadcast();
  List<StreamSubscription<T?>>? subscriptions = [];

  bool? requesting = false;
  bool? requested = false;

  bool shouldRequest() {
    if (requesting == true) {
      return false;
    }
    if (requested == true) {
      return false;
    }
    requesting = true;
    return true;
  }

  void success(T data) {
    requesting = false;
    requested = true;
    try {
      controller?.add(data);
    } catch (e) {
      /// ignored
    }
  }

  void error() {
    requesting = false;
    requested = false;
    try {
      controller?.add(null);
    } catch (e) {
      /// ignored
    }
  }

  StreamSubscription<T?> subscribe(void Function(T?) onData) {
    final subscription = controller?.stream.listen(onData);
    subscriptions?.add(subscription!);
    return subscription!;
  }

  void unsubscribe(StreamSubscription<T?> subscription) {
    subscriptions?.remove(subscription);
  }

  void onceSubscribe(void Function(T?) onData) {
    StreamSubscription<T?>? subscription;

    innerOnData(T? data) {
      onData(data);
      if (subscription != null) {
        subscription.cancel();
        unsubscribe(subscription);
      }
    }

    subscription = subscribe(innerOnData);
  }

  void dispose() {
    for (final subscription in subscriptions ?? []) {
      subscription.cancel();
    }
    subscriptions?.clear();
    subscriptions = null;
    controller?.close();
    controller = null;
    requesting = null;
    requested = null;
  }

  void reset() {
    for (final subscription in subscriptions ?? []) {
      subscription.cancel();
    }
    subscriptions?.clear();
    requesting = false;
    requested = false;
  }
}

class _InternalQuerySongRequest extends _InternalRequest<SongQueryEntity> {
  SongEntity? song;
  SongPrivilegeEntity? privilege;

  void songQueryReceiver(Either<Failure, SongQueryEntity> data) {
    data.fold(
      (failure) {
        error();
      },
      (query) {
        query.map.forEach((songOption, privilege) {
          song = (songOption as IndependentSome<SongEntity>).value;
          this.privilege = privilege;
        });
        success(query);
      },
    );
  }

  @override
  void reset() {
    song = null;
    privilege = null;
    super.reset();
  }

  @override
  void dispose() {
    song = null;
    privilege = null;
    super.dispose();
  }
}

class _InternalDownloadSongFileRequest
    extends _InternalRequest<Stream<List<int>>> {
  SongFileEntity? songFile;

  void downloadPlayerSongFileReceiver(
    Either<Failure, Pair<SongFileEntity, Stream<List<int>>>> data,
  ) {
    data.fold(
      (failure) {
        error();
      },
      (pair) {
        songFile = pair.key;
        success(pair.value);
      },
    );
  }

  @override
  void reset() {
    songFile = null;
    super.reset();
  }

  @override
  void dispose() {
    songFile = null;
    super.dispose();
  }
}

class _InternalGetSongLyricsRequest extends _InternalRequest<LyricsContainer> {
  LyricsContainer? lyricsContainer;
  StreamSubscription? subscription;

  @override
  void success(LyricsContainer data) {
    lyricsContainer = data;
    super.success(data);
  }

  @override
  void reset() {
    lyricsContainer = null;
    super.reset();
  }

  @override
  void dispose() {
    lyricsContainer = null;
    super.dispose();
  }
}

class _FollowerResponseCallbacks {
  String? id;
  void Function(List<int>?)? onCover;
  void Function(SongEntity?)? onSong;
  void Function(SongPrivilegeEntity?)? onSongPrivilege;
  void Function(SongFileEntity?)? onSongFile;
  void Function(LyricsContainer?)? onLyrics;

  _FollowerResponseCallbacks(
    this.id,
    this.onCover,
    this.onSong,
    this.onSongPrivilege,
    this.onSongFile,
    this.onLyrics,
  );

  void cover(List<int>? bytes) {
    if (onCover == null) {
      return;
    }
    onCover?.call(bytes);
  }

  void song(SongEntity? song) {
    if (onSong == null) {
      return;
    }
    onSong?.call(song);
  }

  void privilege(SongPrivilegeEntity? privilege) {
    if (onSongPrivilege == null) {
      return;
    }
    onSongPrivilege?.call(privilege);
  }

  void songFile(SongFileEntity? songFile) {
    if (onSongFile == null) {
      return;
    }
    onSongFile?.call(songFile);
  }

  void lyrics(LyricsContainer? lyrics) {
    if (onLyrics == null) {
      return;
    }
    onLyrics?.call(lyrics);
  }

  void dispose() {
    id = null;
    onCover = null;
    onSong = null;
    onSongPrivilege = null;
    onSongFile = null;
    onLyrics = null;
  }
}

class _InternalRequestFollower {
  Map<String, _FollowerResponseCallbacks>? callbacks = {};

  _InternalRequestFollower();

  void follow({
    required String id,
    void Function(List<int>?)? onCover,
    void Function(SongEntity?)? onSong,
    void Function(SongPrivilegeEntity?)? onSongPrivilege,
    void Function(SongFileEntity?)? onSongFile,
    void Function(LyricsContainer?)? onLyrics,
  }) {
    final callbacks = _FollowerResponseCallbacks(
      id,
      onCover,
      onSong,
      onSongPrivilege,
      onSongFile,
      onLyrics,
    );
    this.callbacks?[id] = callbacks;
  }

  void cover(List<int>? bytes) {
    if (callbacks == null) {
      return;
    }
    for (final callbacks in callbacks!.values) {
      callbacks.cover(bytes);
    }
  }

  void song(SongEntity? song) {
    if (callbacks == null) {
      return;
    }
    for (final callbacks in callbacks!.values) {
      callbacks.song(song);
    }
  }

  void privilege(SongPrivilegeEntity? privilege) {
    if (callbacks == null) {
      return;
    }
    for (final callbacks in callbacks!.values) {
      callbacks.privilege(privilege);
    }
  }

  void songFile(SongFileEntity? songFile) {
    if (callbacks == null) {
      return;
    }
    for (final callbacks in callbacks!.values) {
      callbacks.songFile(songFile);
    }
  }

  void lyrics(LyricsContainer? lyrics) {
    if (callbacks == null) {
      return;
    }
    for (final callbacks in callbacks!.values) {
      callbacks.lyrics(lyrics);
    }
  }

  void call(
    List<int>? cover,
    SongEntity? song,
    SongPrivilegeEntity? privilege,
    SongFileEntity? songFile,
    LyricsContainer? lyrics,
  ) {
    this.cover(cover);
    this.song(song);
    this.privilege(privilege);
    this.songFile(songFile);
    this.lyrics(lyrics);
  }

  void cancel(String id) {
    callbacks?[id]?.dispose();
    callbacks?.remove(id);
  }

  void dispose() {
    if (callbacks == null) {
      return;
    }
    for (final callbacks in callbacks!.values) {
      callbacks.dispose();
    }
    callbacks?.clear();
    callbacks = null;
  }
}

class _InternalBytesReference {
  WeakReference<List<int>>? bytesReference;

  bool available() {
    if (bytesReference == null) {
      return false;
    }

    return bytesReference!.target != null ? bytesReference!.target!.isNotEmpty : false;
  }

  void update(List<int> bytes) {
    bytesReference = WeakReference(bytes);
  }

  List<int>? data() {
    return bytesReference?.target;
  }

  void clear() {
    bytesReference?.target?.clear();
    bytesReference = null;
  }
}

class NetworkStreamAudioSource extends StreamAudioSource {
  final SongBloc songBloc;
  final AlbumBloc albumBloc;
  final int songId;
  bool initialized = false;

  _InternalQuerySongRequest? _querySongRequest;
  _InternalDownloadSongFileRequest? _downloadSongFileRequest;
  _InternalGetSongLyricsRequest? _getSongLyricsRequest;
  _InternalRequestFollower? _requestFollower;
  CoverRequest? coverRequest;

  StreamController<List<int>>? onceOutput;
  _InternalBytesReference? _bytesReference;

  NetworkStreamAudioSource(this.songId, this.songBloc, this.albumBloc);

  void initialize() {
    if (initialized) {
      return;
    }
    initialized = true;

    _querySongRequest ??= _InternalQuerySongRequest();
    _downloadSongFileRequest ??= _InternalDownloadSongFileRequest();
    _getSongLyricsRequest ??= _InternalGetSongLyricsRequest();
    _requestFollower ??= _InternalRequestFollower();
    onceOutput ??= StreamController();
    _bytesReference ??= _InternalBytesReference();
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    initialize();

    bool shouldSongRequest = _querySongRequest?.shouldRequest() ?? false;
    if (!_bytesReference!.available() && !shouldSongRequest) {
      resetSongRequest();
      shouldSongRequest = true;
    }
    if (shouldSongRequest == true) {
      _querySongRequest!.onceSubscribe(onSongQueried);
      songBloc.add(
        AttemptQuerySongEvent([songId], _querySongRequest!.songQueryReceiver),
      );
    }

    bool shouldLyricsRequest = _getSongLyricsRequest?.shouldRequest() ?? false;
    if (shouldLyricsRequest == true) {
      final subscription = songBloc.stream.listen(onLyricsGot);
      _getSongLyricsRequest!.subscription = subscription;
      songBloc.add(AttemptGetSongLyricsEvent(songId));
    }

    if (_bytesReference!.available()) {
      final bytes = _bytesReference!.data()!;
      end ??= bytes.length;
      final controller = apart(bytes, start, end);
      return StreamAudioResponse(
        sourceLength: bytes.length,
        contentLength: end - (start ?? 0),
        offset: start,
        stream: controller!.stream,
        contentType: "audio/mp3",
      );
    } else {
      if (onceOutput?.isClosed == false) {
        onceOutput?.close();
      }
      onceOutput = StreamController();
    }

    return StreamAudioResponse(
      sourceLength: null,
      contentLength: null,
      offset: null,
      stream: onceOutput!.stream,
      contentType: "audio/mp3",
    );
  }

  StreamController<List<int>>? apart(List<int> bytes, int? start, int? end) {
    final chunkSize = 1024 * 1024;
    int current = start ?? 0;
    end ??= bytes.length;
    if (end > bytes.length) {
      end = bytes.length;
    }

    final controller = StreamController<List<int>>();
    controller.onListen = () async {
      while (current < end! && !controller.isClosed) {
        final chunkEnd =
            (current + chunkSize < end) ? current + chunkSize : end;
        final chunk = bytes.sublist(current, chunkEnd);
        controller.add(chunk);
        current = chunkEnd;
        await Future.delayed(Duration.zero);
      }
      if (!controller.isClosed) {
        controller.close();
      }
    };

    return controller;
  }

  void onLyricsGot(SongState songState) {
    if (songState is GetSongLyricsFailure) {
      _getSongLyricsRequest?.subscription?.cancel();
      _getSongLyricsRequest?.subscription = null;
      _getSongLyricsRequest?.error();
      return;
    }
    if (songState is! GetSongLyricsSuccess) {
      return;
    }
    _getSongLyricsRequest?.subscription?.cancel();
    _getSongLyricsRequest?.subscription = null;
    _getSongLyricsRequest?.success(songState.lyricsContainer);
    _requestFollower?.lyrics(songState.lyricsContainer);
  }

  void onSongQueried(SongQueryEntity? _) {
    final song = _querySongRequest?.song;
    final privilege = _querySongRequest?.privilege;
    if (song == null || privilege == null) {
      resetSongRequest();
      return;
    }
    _requestFollower?.song(song);
    _requestFollower?.privilege(privilege);

    coverRequest ??= CoverRequest.fromSong(song);
    if (coverRequest == null) {
      resetSongRequest();
      return;
    }

    final shouldCoverRequest = coverRequest!.shouldRequest();
    if (shouldCoverRequest) {
      albumBloc.add(
        AttemptGetAlbumCoverEvent(
          coverRequest!.id,
          coverRequest!.url,
          onCoverReceiver,
        ),
      );
    }

    final shouldSongRequest =
        _downloadSongFileRequest?.shouldRequest() ?? false;
    if (shouldSongRequest == true) {
      _downloadSongFileRequest!.onceSubscribe(onSongFileDownloaded);
      songBloc.add(
        AttemptDownloadPlayerSongFilesEvent(
          [songId],
          privilege.playQuality,
          _downloadSongFileRequest!.downloadPlayerSongFileReceiver,
        ),
      );
    }
  }

  void onCoverReceiver(Either<Failure, ImageItemResult> data) {
    if (coverRequest == null) {
      return;
    }
    data.fold(
      (failure) {
        _requestFollower?.cover(null);
      },
      (result) {
        _requestFollower?.cover(result.bytes);
      },
    );
    coverRequest!.coverReceiver(data);
  }

  void onSongFileDownloaded(Stream<List<int>>? stream) {
    if (stream == null) {
      resetSongRequest();
      return;
    }

    _requestFollower?.songFile(_downloadSongFileRequest?.songFile);

    final tempBytes = <int>[];
    stream.listen(
      (data) {
        if (onceOutput?.isClosed == true) {
          resetSongRequest();
          return;
        }
        tempBytes.addAll(data);
        onceOutput?.add(data);
      },
      onDone: () {
        _bytesReference?.update(tempBytes);
        onceOutput?.close();
        onceOutput = null;
      },
      onError: (e, s) {
        resetSongRequest();
      },
    );
  }

  void resetSongRequest() {
    _bytesReference?.clear();
    _downloadSongFileRequest?.reset();
    if (onceOutput?.isClosed == false) {
      onceOutput?.close();
    }
    onceOutput = StreamController();
    coverRequest = null;
  }

  void Function() followRequest({
    required String id,
    void Function(List<int>?)? onCover,
    void Function(SongEntity?)? onSong,
    void Function(SongPrivilegeEntity?)? onSongPrivilege,
    void Function(SongFileEntity?)? onSongFile,
    void Function(LyricsContainer?)? onLyrics,
  }) {
    _requestFollower ??= _InternalRequestFollower();

    _requestFollower?.follow(
      id: id,
      onCover: onCover,
      onSong: onSong,
      onSongPrivilege: onSongPrivilege,
      onSongFile: onSongFile,
      onLyrics: onLyrics
    );
    _requestFollower?.call(
      coverRequest?.notifier?.value,
      _querySongRequest?.song,
      _querySongRequest?.privilege,
      _downloadSongFileRequest?.songFile,
      _getSongLyricsRequest?.lyricsContainer
    );

    return () {
      _requestFollower?.cancel(id);
    };
  }

  void dispose() {
    _querySongRequest?.dispose();
    _querySongRequest = null;
    _downloadSongFileRequest?.dispose();
    _downloadSongFileRequest = null;
    _getSongLyricsRequest?.dispose();
    _getSongLyricsRequest = null;
    _requestFollower?.dispose();
    _requestFollower = null;
    coverRequest?.dispose();
    coverRequest = null;
    onceOutput?.close();
    onceOutput = null;
    _bytesReference?.clear();
    _bytesReference = null;
  }
}
