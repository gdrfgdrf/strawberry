import 'package:dartz/dartz.dart' hide State;
import 'package:domain/entity/playlist_query_entity.dart';
import 'package:domain/entity/playlists_entity.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/bloc/playlist/get_playlist_cover_event_state.dart';
import 'package:strawberry/bloc/playlist/playlist_bloc.dart';
import 'package:strawberry/bloc/user/get_user_avatar_event_state.dart';
import 'package:strawberry/bloc/user/user_bloc.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/list/song/song_list.dart';
import 'package:strawberry/ui/slivertracker/scroll_view_listener.dart';
import 'package:strawberry/ui/slivertracker/sliver_scroll_listener.dart';
import 'package:widgets/animation/overflow_widget_wrapper.dart';
import 'package:widgets/widgets/an_error_widget.dart';
import 'package:widgets/widgets/loading_widget.dart';
import 'package:widgets/widgets/next_smooth_image.dart';

import '../../../bloc/playlist/query_playlist_event_state.dart';

class PlaylistPageMobile extends AbstractUiWidget {
  final PlaylistItemEntity playlist;

  const PlaylistPageMobile({super.key, required this.playlist});

  @override
  State<StatefulWidget> createState() => _PlaylistPageMobileState();
}

class _PlaylistPageMobileState
    extends AbstractUiWidgetState<PlaylistPageMobile, EmptyDelegate> {
  final PlaylistBloc playlistBloc = GetIt.instance.get();
  final UserBloc userBloc = GetIt.instance.get();
  final ValueNotifier<List<int>?> coverBytesNotifier = ValueNotifier(null);
  final ValueNotifier<List<int>?> avatarNotifier = ValueNotifier(null);
  final ValueNotifier<Either<Failure, PlaylistQueryEntity>?> idsNotifier =
      ValueNotifier(null);
  final SearchController searchController = SearchController();

  @override
  EmptyDelegate createDelegate() {
    return EmptyDelegate.instance;
  }

  void coverReceiver(Either<Failure, ImageItemResult> data) {
    data.fold((failure) {}, (result) async {
      coverBytesNotifier.value = result.bytes;
    });
  }

  void avatarReceiver(Either<Failure, ImageItemResult> data) {
    data.fold((failure) {}, (result) {
      avatarNotifier.value = result.bytes;
    });
  }

  @override
  List<VoidCallback> postListeners() {
    return [
      () {
        playlistBloc.add(
          AttemptGetPlaylistCoverEvent(
            widget.playlist.id,
            widget.playlist.coverImgUrl,
            coverReceiver,
          ),
        );
        playlistBloc.add(AttemptQueryBasicPlaylistEvent(widget.playlist.id));
        userBloc.add(
          AttemptGetUserAvatarEvent(
            widget.playlist.creator.userId,
            avatarReceiver,
          ),
        );
      },
    ];
  }

  @override
  List<BlocListener<StateStreamable, dynamic>> blocListeners() {
    return [
      BlocListener(
        bloc: playlistBloc,
        listener: (context, state) {
          if (state is QueryBasicPlaylistSuccess) {
            idsNotifier.value = Right(state.playlistQuery);
          }
          if (state is PlaylistFailure) {
            idsNotifier.value = Left(state.failure);
          }
        },
      ),
    ];
  }

  @override
  void dispose() {
    playlistBloc.close();
    coverBytesNotifier.dispose();
    avatarNotifier.dispose();
    idsNotifier.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget buildSearchBar() {
    final iconId = ConstraintId("icon");

    return SmoothContainer(
      width: 240.w,
      height: 64,
      borderRadius: BorderRadius.circular(24),
      color: themeData().colorScheme.surfaceContainerHigh,
      alignment: Alignment.centerRight,
      child: ConstraintLayout(
        children: [
          Icon(
            size: 24,
            Icons.search_rounded,
            color: themeData().colorScheme.onSurfaceVariant,
          ).applyConstraint(
            id: iconId,
            top: parent.top,
            bottom: parent.bottom,
            left: parent.left,
            margin: EdgeInsets.only(left: 12),
          ),

          SmoothContainer(
            width: 240.w - 24 - 12,
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
              onChanged: (text) {
                searchController.value = TextEditingValue(text: text);
              },
            ),
          ).applyConstraint(
            top: parent.top,
            bottom: parent.bottom,
            left: iconId.right,
          ),
        ],
      ),
    );
  }

  Widget buildListBody() {
    return ValueListenableBuilder(
      valueListenable: idsNotifier,
      builder: (context, data, _) {
        if (data == null) {
          return SliverToBoxAdapter(child: LoadingWidget());
        }
        return data.fold(
          (failure) {
            return SliverToBoxAdapter(child: AnErrorWidget());
          },
          (query) {
            final songIds = query.songIds;

            final ids = <int>[];
            final addTimes = <int, int>{};

            for (final songId in songIds) {
              ids.add(songId.id);
              addTimes[songId.id] = songId.addTime;
            }

            return SongList(
              ids: ids,
              addTimes: addTimes,
              searchController: searchController,
              lovedPlaylist: query.lovedPlaylist(),
            );
          },
        );
      },
    );
  }

  Widget buildTopBody() {
    final size = MediaQuery.of(context).size;
    final coverId = ConstraintId("cover");
    final nameId = ConstraintId("name");
    final avatarId = ConstraintId("avatar");

    return SizedBox(
      height: 180.w,
      child: ConstraintLayout(
        children: [
          NextSmoothImage.notifier(
            width: 128.w,
            height: 128.w,
            notifier: coverBytesNotifier,
            borderRadius: BorderRadius.circular(16),
          ).applyConstraint(
            id: coverId,
            left: parent.left,
            top: parent.top,
            margin: EdgeInsets.only(
              top: (180.w - 128.w) / 2,
              left: (180.w - 128.w) / 2,
            ),
          ),

          SmoothContainer(
            width: size.width - 180.w + 128.w - 128.w - 4,
            height: 28.w,
            child: OverflowWidgetWrapper.create(
              child: Text(
                widget.playlist.name,
                style: TextStyle(fontSize: 20.sp),
              ),
              maxWidth: double.infinity,
              maxHeight: 28.w,
            ),
          ).applyConstraint(
            id: nameId,
            left: coverId.right,
            top: coverId.top,
            margin: EdgeInsets.only(top: 4, left: 4),
          ),

          NextSmoothImage.notifier(
            width: 36.w,
            height: 36.w,
            borderRadius: BorderRadius.circular(16),
            notifier: avatarNotifier,
          ).applyConstraint(
            id: avatarId,
            left: coverId.right,
            top: nameId.bottom,
            margin: EdgeInsets.only(top: 4, left: 4),
          ),

          SmoothContainer(
            width: size.width - 180.w + 128.w - 128.w - 4 - 36.w,
            height: 36.w,
            alignment: Alignment.centerLeft,
            child: OverflowWidgetWrapper.create(
              child: Text(
                widget.playlist.creator.nickname,
                style: TextStyle(fontSize: 12.sp),
              ),
              maxWidth: double.infinity,
              maxHeight: 36.w,
            ),
          ).applyConstraint(
            top: avatarId.top,
            bottom: avatarId.bottom,
            left: avatarId.right,
            margin: EdgeInsets.only(left: 4),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: coverBytesNotifier,
      builder: (context, bytes, _) {
        if (bytes == null) {
          return LoadingWidget();
        }
        return ScrollViewListener(
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: buildTopBody()),
              SliverPadding(
                padding: EdgeInsets.only(top: 6, left: 36.w, right: 16),
                sliver: SliverToBoxAdapter(child: buildSearchBar()),
              ),
              SliverPadding(
                padding: EdgeInsets.only(top: 16, bottom: 64.w),
                sliver: buildListBody(),
              ),
            ],
          ),
        );
      },
    );
  }
}
