import 'dart:typed_data';

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
import 'package:strawberry/bloc/playlist/query_playlist_event_state.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/list/song/song_list.dart';
import 'package:widgets/widgets/an_error_widget.dart';
import 'package:widgets/widgets/copyable_text.dart';
import 'package:widgets/widgets/loading_widget.dart';
import 'package:widgets/widgets/next_smooth_image.dart';

class PlaylistPageDesktop extends AbstractUiWidget {
  final PlaylistItemEntity playlist;

  const PlaylistPageDesktop({super.key, required this.playlist});

  @override
  State<StatefulWidget> createState() => _PlaylistDesktopPageState();
}

class _PlaylistDesktopPageState
    extends AbstractUiWidgetState<PlaylistPageDesktop, EmptyDelegate> {
  final PlaylistBloc playlistBloc = GetIt.instance.get();
  final ValueNotifier<Either<Failure, List<int>>?> coverBytesNotifier =
      ValueNotifier(null);
  final ValueNotifier<Either<Failure, List<PlaylistSongId>>?> idsNotifier =
      ValueNotifier(null);
  final SearchController searchController = SearchController();

  @override
  EmptyDelegate createDelegate() {
    return EmptyDelegate.instance;
  }

  void coverReceiver(Either<Failure, ImageItemResult> data) {
    data.fold(
      (failure) {
        coverBytesNotifier.value = Left(failure);
      },
      (result) {
        coverBytesNotifier.value = Right(result.bytes);
      },
    );
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
            idsNotifier.value = Right(state.playlistQuery.songIds);
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
    idsNotifier.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget buildTop() {
    final coverId = ConstraintId("cover");
    final nameId = ConstraintId("name");

    return SliverToBoxAdapter(
      child: Material(
        color: Colors.transparent,
        child: SmoothContainer(
          height: 230.h,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          child: ConstraintLayout(
            children: [
              ValueListenableBuilder(
                valueListenable: coverBytesNotifier,
                builder: (context, data, _) {
                  if (data == null) {
                    return LoadingWidget();
                  }
                  if (data.isLeft()) {
                    return AnErrorWidget();
                  }
                  return data.fold(
                    (failure) {
                      return AnErrorWidget();
                    },
                    (bytes) {
                      return NextSmoothImage.streamController(
                        width: 128.w,
                        height: 128.w,
                        borderRadius: BorderRadius.circular(16),
                        onStreamController: (streamController) {
                          streamController.add(
                            MemoryImage(Uint8List.fromList(bytes)),
                          );
                        },
                      );
                    },
                  );
                },
              ).applyConstraint(
                id: coverId,
                left: parent.left,
                top: parent.top,
                margin: EdgeInsets.only(top: 48, left: 48),
              ),

              SmoothContainer(
                height: 36.w,
                child: Text(
                  widget.playlist.name,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ).applyConstraint(
                id: nameId,
                top: coverId.top,
                left: coverId.right,
                margin: EdgeInsets.only(top: 6, left: 12),
              ),

              SmoothContainer(
                width: 1000.w,
                height: 92.w,
                child: CopyableText(text: widget.playlist.description ?? ""),
              ).applyConstraint(
                top: nameId.bottom,
                left: coverId.right,
                margin: EdgeInsets.only(left: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    final iconId = ConstraintId("icon");

    return SliverPadding(
      padding: EdgeInsets.only(top: 24, left: 1440.w - 240.w - 24, right: 24),
      sliver: SliverToBoxAdapter(
        child: SmoothContainer(
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
        ),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        buildTop(),
        buildSearchBar(),

        SliverPadding(
          padding: EdgeInsets.only(top: 12, bottom: 64.w),
          sliver: ValueListenableBuilder(
            valueListenable: idsNotifier,
            builder: (context, data, _) {
              if (data == null) {
                return SliverToBoxAdapter(child: LoadingWidget());
              }

              return data.fold(
                    (failure) {
                  return SliverToBoxAdapter(child: AnErrorWidget());
                },
                    (songIds) {
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
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
