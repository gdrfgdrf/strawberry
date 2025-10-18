import 'package:dartz/dartz.dart' hide State;
import 'package:domain/entity/playlists_entity.dart';
import 'package:domain/result/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:shared/platform_extension.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/bloc/playlist/get_playlist_cover_event_state.dart';
import 'package:strawberry/bloc/playlist/get_playlists_event_state.dart';
import 'package:strawberry/bloc/playlist/playlist_bloc.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/list/cover_request.dart';
import 'package:strawberry/ui/list/playlists_grid_delegate.dart';
import 'package:widgets/animation/overflow_widget_wrapper.dart';
import 'package:widgets/widgets/an_error_widget.dart';
import 'package:widgets/widgets/loading_widget.dart';
import 'package:widgets/widgets/next_smooth_image.dart';

class PlaylistsGrid extends AbstractUiWidget {
  final PlaylistSource source;
  final int userId;
  final void Function(PlaylistItemEntity)? onClick;

  const PlaylistsGrid({
    super.key,
    required this.source,
    required this.userId,
    this.onClick,
  });

  @override
  State<StatefulWidget> createState() => _PlaylistsGridState();
}

class _PlaylistsGridState
    extends AbstractUiWidgetState<PlaylistsGrid, PlaylistsGridDelegate> {
  final ValueNotifier<Either<Failure, PlaylistsEntity>?> playlistsNotifier =
      ValueNotifier(null);
  final List<CoverRequest> coverRequests = [];

  PlaylistsEntity? playlists;

  @override
  PlaylistsGridDelegate createDelegate() {
    return PlaylistsGridDelegate();
  }

  @override
  List<VoidCallback> postListeners() {
    return [
      () {
        delegate!.playlistBloc.add(
          AttemptGetPlaylistsEvent(widget.userId, widget.source),
        );
      },
    ];
  }

  @override
  List<BlocListener<StateStreamable, dynamic>> blocListeners() {
    return [
      BlocListener(
        bloc: delegate!.playlistBloc,
        listener: (context, state) {
          if (state is GetPlaylistsSuccess) {
            final playlists = state.playlists;
            playlistsNotifier.value = Right(playlists);
          }
          if (state is GetPlaylistsFailure) {
            playlistsNotifier.value = Left(state.failure);
          }
        },
      ),
    ];
  }

  @override
  void dispose() {
    playlistsNotifier.dispose();
    for (final request in coverRequests) {
      request.dispose();
    }
    super.dispose();
  }

  Widget buildItem(int index) {
    if (playlists == null) {
      return LoadingWidget();
    }

    final playlist = playlists!.playlists[index];
    final name = playlist.name;

    final coverRequest = coverRequests[index];
    final shouldRequest = coverRequest.shouldRequest();
    if (shouldRequest) {
      delegate!.playlistBloc.add(
        AttemptGetPlaylistCoverEvent(
          int.parse(coverRequest.id),
          coverRequest.url,
          coverRequest.coverReceiver,
        ),
      );
    }

    final coverId = ConstraintId("cover");
    final nameId = ConstraintId("name");
    final dividerId = ConstraintId("divider");

    return GestureDetector(
      onTap: () {
        widget.onClick?.call(playlist);
      },
      child: Material(
        elevation: 8,
        color: Colors.transparent,
        child: SmoothContainer(
          borderRadius: BorderRadius.circular(16),
          color: themeData().colorScheme.surfaceContainerHigh,
          child: ConstraintLayout(
            children: [
              NextSmoothImage.notifier(
                borderRadius: BorderRadius.circular(16),
                placeholder: LoadingWidget(),
                notifier: coverRequest.notifier!,
              ).applyConstraint(
                id: coverId,
                left: parent.left,
                right: parent.right,
                top: parent.top,
                bottom: dividerId.top,
              ),

              Divider().applyConstraint(
                id: dividerId,
                bottom: nameId.top,
                left: parent.left,
                right: parent.right,
              ),

              SizedBox(
                child: OverflowWidgetWrapper.create(
                  child: Text(name),
                  maxWidth: double.infinity,
                  maxHeight: 24,
                ),
              ).applyConstraint(
                id: nameId,
                left: parent.left,
                right: parent.right,
                bottom: parent.bottom,
                margin: EdgeInsets.only(bottom: 6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGrid() {
    int crossAxisCount = 4;
    if (PlatformExtension.isMobile) {
      crossAxisCount = 2;
    }
    final itemWidth = 64;
    final itemHeight = 64 + 12;
    final childAspectRatio = itemWidth / itemHeight;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        return buildItem(index);
      }, childCount: playlists!.playlists.length),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: playlistsNotifier,
      builder: (context, data, _) {
        if (data == null) {
          return SliverToBoxAdapter(child: LoadingWidget());
        }

        return data.fold(
          (failure) {
            return SliverToBoxAdapter(child: AnErrorWidget());
          },
          (playlists) {
            this.playlists = playlists;
            for (final playlist in playlists.playlists) {
              final id = playlist.id;
              final coverUrl = playlist.coverImgUrl;

              final coverRequest = CoverRequest(id.toString(), coverUrl);
              coverRequests.add(coverRequest);
            }

            return buildGrid();
          },
        );
      },
    );
  }
}
