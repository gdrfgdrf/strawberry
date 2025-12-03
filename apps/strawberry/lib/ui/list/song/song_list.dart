import 'dart:ui';

import 'package:dartz/dartz.dart' hide State;
import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_privilege_entity.dart';
import 'package:domain/entity/song_query_entity.dart';
import 'package:domain/loved_playlist_ids_holder.dart';
import 'package:domain/result/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:natives/ffi/atomic.dart';
import 'package:shared/files.dart';
import 'package:shared/string_extension.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/bloc/album/album_bloc.dart';
import 'package:strawberry/bloc/album/get_album_cover_event_state.dart';
import 'package:strawberry/bloc/song/query_song_event_state.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';
import 'package:strawberry/bloc/user/user_bloc.dart';
import 'package:strawberry/bloc/user/user_habit_event_state.dart';
import 'package:strawberry/play/playlist_manager.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/list/cover_request.dart';
import 'package:strawberry/ui/slivertracker/sliver_multi_box_scroll_listener_debounce.dart';
import 'package:widgets/widgets/an_error_widget.dart';
import 'package:widgets/widgets/contextmenu/context_menu_wrapper.dart';
import 'package:widgets/widgets/loading_widget.dart';
import 'package:widgets/widgets/next_smooth_image.dart';

class _InternalSongWrapper {
  final SongEntity song;
  final SongPrivilegeEntity privilege;

  const _InternalSongWrapper(this.song, this.privilege);

  @override
  bool operator ==(Object other) {
    if (other is! _InternalSongWrapper) {
      return false;
    }
    if (song.id != other.song.id) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => song.id.hashCode;
}

class SongList extends AbstractUiWidget {
  final List<int> ids;
  final Map<int, int>? addTimes;
  final SearchController? searchController;
  final bool lovedPlaylist;

  const SongList({
    super.key,
    required this.ids,
    this.addTimes,
    this.searchController,
    this.lovedPlaylist = false,
  });

  @override
  State<StatefulWidget> createState() => _SongListState();
}

class _SongListState extends AbstractUiWidgetState<SongList, EmptyDelegate> {
  ValueNotifier<Either<Failure, List<_InternalSongWrapper>>?>? notifier =
      ValueNotifier(null);

  AlbumBloc? albumBloc = GetIt.instance.get();
  SongBloc? songBloc = GetIt.instance.get();
  UserBloc? userBloc = GetIt.instance.get();

  AtomicBoolImpl? songQueryFinished = AtomicApi.createBool(initial: false);
  AtomicCounter? queriedSongCount = AtomicApi.createCounter(initial: 0);

  List<_InternalSongWrapper>? songs = [];
  List<CoverRequest>? coverRequests = [];
  List<_InternalSongWrapper>? searches = [];
  String? sha256;

  bool? firstScrollUpdate = false;

  @override
  EmptyDelegate createDelegate() {
    return EmptyDelegate.instance;
  }

  @override
  List<VoidCallback> postListeners() {
    return [
      () {
        if (widget.lovedPlaylist) {
          GetIt.instance.get<LovedPlaylistIdsHolder>().update(widget.ids);
        }
        songBloc?.add(AttemptQuerySongEvent(widget.ids, songReceiver));
      },
    ];
  }

  String? buildSongIds() {
    final buffer = StringBuffer();
    for (final songWrapper in songs!) {
      final song = songWrapper.song;
      final id = song.id;
      buffer.write("$id,");
    }
    final result = buffer.toString();
    final substring = result.substring(0, result.length - 1);
    return substring;
  }

  Future<String?> calculateSha256() async {
    if (sha256 != null) {
      return sha256;
    }
    if (songs == null || songs?.isEmpty == true) {
      return null;
    }

    final songIds = buildSongIds();
    if (songIds == null) {
      return null;
    }

    final calculated = await Files.sha256(songIds.codeUnits);
    sha256 = calculated;
    return calculated;
  }

  void play(int index) async {
    if (songs == null || songs?.isEmpty == true) {
      return;
    }

    final playlistManager = GetIt.instance.get<PlaylistManager>();
    final currentSha256 = playlistManager.getCurrentSha256();
    final sha256 = await calculateSha256();
    if (sha256 == null) {
      return;
    }

    if (currentSha256 != null && currentSha256 == sha256) {
      playlistManager.playAt(index);
      return;
    }

    final units =
        songs!.map((wrapper) {
          return PlaylistUnit(wrapper.song.id, null);
        }).toList();
    await playlistManager.replace(sha256, units);
    await playlistManager.playAt(index);

    userBloc?.add(AttemptStoreUserHabitEvent("song-list-sha256", sha256));
    userBloc?.add(AttemptStoreUserHabitEvent("song-list-ids", buildSongIds()));
  }

  void checkQueriedSongCount() {
    if (queriedSongCount == null ||
        songQueryFinished == null ||
        songQueryFinished?.get_() == true) {
      return;
    }

    final value = queriedSongCount!.increment();

    if (value >= widget.ids.length) {
      songQueryFinished!.set_(value: true);

      if (widget.addTimes != null) {
        songs?.sort((first, second) {
          final id1 = first.song.id;
          final id2 = second.song.id;

          final addTime1 = widget.addTimes![id1];
          final addTime2 = widget.addTimes![id2];

          if (addTime1 == null || addTime2 == null) {
            return id1.compareTo(id2);
          }

          /// reverse to make sure the latest song is on the top
          return addTime2.compareTo(addTime1);
        });
      }

      if (songs == null) {
        widget.searchController?.addListener(onSearchChanged);
        notifier?.value = Right([]);
        return;
      }

      final needRemove = <int>[];
      for (int i = 0; i < songs!.length; i++) {
        final songWrapper = songs![i];
        final song = songWrapper.song;

        final coverRequest = CoverRequest.fromSong(song);
        if (coverRequest == null) {
          continue;
        }

        coverRequests?.add(coverRequest);
        searches?.add(songWrapper);
      }
      for (final index in needRemove) {
        songs?.removeAt(index);
      }

      /// 下面那个 SliverScrollListenerDebounce 如果没有第一次滑动的话，
      /// onScrollEnd 不会执行，就不会发 request，所以需要预先加载一些
      if (songs!.length >= 20) {
        for (int i = 0; i < 20; i++) {
          request(i);
        }
      } else {
        for (int i = 0; i < songs!.length; i++) {
          request(i);
        }
      }

      widget.searchController?.addListener(onSearchChanged);
      notifier?.value = Right(songs!);
    }
  }

  void songReceiver(Either<Failure, SongQueryEntity> data) {
    data.fold(
      (failure) {
        checkQueriedSongCount();
      },
      (queries) {
        for (final entry in queries.map.entries) {
          final songOption = entry.key;

          if (songOption is IndependentSome<SongEntity>) {
            final song = songOption.value;
            final privilege = entry.value;
            final wrapper = _InternalSongWrapper(song, privilege);
            songs?.add(wrapper);
          }
        }
        checkQueriedSongCount();
      },
    );
  }

  Widget buildInnerItem(SongEntity song, CoverRequest coverRequest) {
    final coverId = ConstraintId("cover");
    final nameId = ConstraintId("name");

    return SmoothContainer(
      height: 64.w,
      borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
      color: themeData().colorScheme.surfaceContainerHigh,
      child: ConstraintLayout(
        children: [
          SmoothContainer(
            width: 36.w,
            height: 36.w,
            color: themeData().colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            child: NextSmoothImage.notifier(
              width: 36.w,
              height: 36.w,
              borderRadius: BorderRadius.circular(8),
              notifier: coverRequest.notifier!,
            ),
          ).applyConstraint(
            id: coverId,
            top: parent.top,
            bottom: parent.bottom,
            left: parent.left,
            margin: EdgeInsets.only(left: 16.w),
          ),

          Text(song.name, style: TextStyle(fontSize: 11.sp)).applyConstraint(
            id: nameId,
            top: coverId.top,
            left: coverId.right,
            margin: EdgeInsets.only(top: 2, left: 4),
          ),

          Text(
            song.buildArtists(),
            style: TextStyle(fontSize: 10.sp),
          ).applyConstraint(
            top: nameId.bottom,
            left: coverId.right,
            margin: EdgeInsets.only(left: 4),
          ),
        ],
      ),
    );
  }

  void request(int index) {
    if (songs?.isEmpty == true ||
        songs == null ||
        searches == null ||
        coverRequests == null) {
      return;
    }

    final songWrapper = searches![index];
    final indexInSongs = songs!.indexOf(songWrapper);

    final coverRequest = coverRequests?[indexInSongs];
    final shouldRequest = coverRequest?.shouldRequest();
    if (shouldRequest == true) {
      albumBloc?.add(
        AttemptGetAlbumCoverEvent(
          coverRequest!.id,
          coverRequest.url,
          coverRequest.coverReceiver,
          width: 128,
          height: 128,
        ),
      );
    }
  }

  Widget buildItem(int index) {
    if (songs?.isEmpty == true || songs == null) {
      return LoadingWidget();
    }

    final songWrapper = searches?[index];
    if (songWrapper == null) {
      return LoadingWidget();
    }

    final song = songWrapper.song;
    final indexInSongs = songs!.indexOf(songWrapper);
    final coverRequest = coverRequests?[indexInSongs];
    if (coverRequest == null) {
      return LoadingWidget();
    }

    final chipId = ConstraintId("chip");
    return GestureDetector(
      key: UniqueKey(),
      onTapUp: (details) {
        final kind = details.kind;
        if (kind == PointerDeviceKind.mouse) {
          return;
        }
        play(indexInSongs);
      },
      onDoubleTap: () {
        play(indexInSongs);
      },
      child: ContextMenuWrapper(
        entries: [
          MenuItem(label: Text("Content 1"), icon: Icon(Icons.music_note)),
          MenuItem(label: Text("Content 2"), icon: Icon(Icons.book)),
          MenuItem(label: Text("Content 3"), icon: Icon(Icons.mouse)),
        ],
        child: SmoothContainer(
          width: 1440.w,
          height: 64.w,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
          color: themeData().colorScheme.surfaceContainerLow,
          child: ConstraintLayout(
            children: [
              SmoothContainer(
                height: 24.w,
                child: Text(
                  indexInSongs.toString(),
                  style: TextStyle(fontSize: 12.sp),
                ),
              ).applyConstraint(
                id: chipId,
                top: parent.top,
                bottom: parent.bottom,
                left: parent.left,
                margin: EdgeInsets.only(left: 6.w),
              ),
              buildInnerItem(song, coverRequest).applyConstraint(
                top: parent.top,
                bottom: parent.bottom,
                left: chipId.right,
                margin: EdgeInsets.only(left: 6.w),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: searches?.length ?? 0, (
        context,
        index,
      ) {
        return SliverMultiBoxScrollListenerDebounce(
          debounce: Duration(milliseconds: 500),
          onScrollEnd: (percent) {
            if (percent > 0.5) {
              request(index);
            }
          },
          builder: null,
          child: Padding(
            padding: EdgeInsets.only(left: 36.w, bottom: 12),
            child: buildItem(index),
          ),
        );
      }),
    );
  }

  void onSearchChanged() {
    search(widget.searchController?.text ?? "");
  }

  void search(String string) {
    if (string.isBlank()) {
      searches = [];
      searches?.addAll(songs ?? []);
      notifier?.value = Right(searches ?? []);
      return;
    }

    final searchResult = <_InternalSongWrapper>[];
    for (final songWrapper in songs ?? []) {
      final song = songWrapper.song;
      final matched = song.search(string);

      if (matched) {
        searchResult.add(songWrapper);
      }
    }

    searches = [];
    searches?.addAll(searchResult);

    if (searches!.length >= 20) {
      for (int i = 0; i < 20; i++) {
        request(i);
      }
    } else {
      for (int i = 0; i < searches!.length; i++) {
        request(i);
      }
    }

    notifier?.value = Right(searches ?? []);
  }

  @override
  void dispose() {
    queriedSongCount?.dispose();
    queriedSongCount = null;
    songQueryFinished?.dispose();
    songQueryFinished = null;
    notifier?.dispose();
    notifier = null;
    albumBloc?.close();
    albumBloc = null;
    songBloc?.close();
    songBloc = null;
    userBloc?.close();
    userBloc = null;
    songs?.clear();
    songs = null;
    for (final request in coverRequests ?? []) {
      request.dispose();
    }
    coverRequests?.clear();
    coverRequests = null;
    searches?.clear();
    searches = null;
    widget.searchController?.removeListener(onSearchChanged);
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier!,
      builder: (context, data, _) {
        if (data == null) {
          return SliverToBoxAdapter(child: LoadingWidget());
        }

        return data.fold(
          (failure) {
            return SliverToBoxAdapter(child: AnErrorWidget());
          },
          (songs) {
            return buildList();
          },
        );
      },
    );
  }
}
