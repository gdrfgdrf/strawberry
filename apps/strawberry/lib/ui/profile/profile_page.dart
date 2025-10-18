import 'package:domain/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/bloc/playlist/playlist_bloc.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/list/playlists_grid.dart';
import 'package:strawberry/ui/profile/profile_sheet_controller.dart';
import 'package:widgets/animation/overflow_widget_wrapper.dart';
import 'package:widgets/widgets/copyable_text.dart';
import 'package:widgets/widgets/loading_widget.dart';
import 'package:widgets/widgets/next_smooth_image.dart';
import 'package:widgets/widgets/smooth_dropdown_menu.dart';
import 'package:widgets/widgets/smooth_image.dart';

import '../../bloc/user/get_user_detail_event_state.dart';
import '../profile/profile_page_delegate.dart';

class ProfilePage extends AbstractUiWidget {
  final ProfileSheetController controller;

  const ProfilePage({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState
    extends AbstractUiWidgetState<ProfilePage, ProfilePageDelegate> {
  @override
  ProfilePageDelegate createDelegate() {
    return ProfilePageDelegate();
  }

  @override
  List<VoidCallback> postListeners() {
    return [
      () {
        delegate!.tryGetUserDetail(widget.controller.userId);
        // delegate!.tryGetUserDetail(9003);
      },
    ];
  }

  @override
  List<BlocListener<StateStreamable, dynamic>> blocListeners() {
    return [
      BlocListener(
        bloc: delegate!.userBloc,
        listener: (context, state) {
          if (state is GetUserDetailSuccess_Type1) {
            final profile = state.profile;
            delegate!.profileNotifier.value = profile;
            delegate!.tryFetchAvatar();
          }
        },
      ),
    ];
  }

  Widget buildUserCard() {
    final avatarId = ConstraintId("avatar");
    final usernameId = ConstraintId("username");

    return ConstraintLayout(
      children: [
        SmoothContainer(
          width: 128.w,
          height: 128.w,
          borderRadius: BorderRadius.circular(24),
          color: themeData().colorScheme.surfaceContainerHigh,
          child: NextSmoothImage.notifier(
            width: 128.w,
            height: 128.w,
            borderRadius: BorderRadius.circular(24),
            notifier: delegate!.avatarNotifier,
          ),
        ).applyConstraint(
          id: avatarId,
          left: parent.left,
          top: parent.top,
          bottom: parent.bottom,
          margin: EdgeInsets.only(left: 24.w, top: 24.h),
        ),

        SizedBox(
          child: ValueListenableBuilder(
            valueListenable: delegate!.profileNotifier,
            builder: (context, profile, _) {
              if (profile == null) {
                return Text(
                  "Loading",
                  style: TextStyle(fontSize: 20.sp),
                  textAlign: TextAlign.center,
                );
              }

              return OverflowWidgetWrapper.create(
                child: Text(
                  profile.nickname,
                  style: TextStyle(fontSize: 20.sp),
                  textAlign: TextAlign.center,
                ),
                maxWidth: double.infinity,
                maxHeight: 28.w,
              );
            },
          ),
        ).applyConstraint(
          id: usernameId,
          left: avatarId.right,
          top: avatarId.top,
          margin: EdgeInsets.only(left: 12, top: 2),
        ),

        SmoothContainer(
          width: 800 - 128.w - 24.w - 24.w,
          height: 128.w - 28.w - 12,
          child: ValueListenableBuilder(
            valueListenable: delegate!.profileNotifier,
            builder: (context, profile, _) {
              String? description = "Loading";
              if (profile != null) {
                description = profile.signature;
              }

              return CopyableText(text: description);
            },
          ),
        ).applyConstraint(
          left: avatarId.right,
          top: usernameId.bottom,
          margin: EdgeInsets.only(left: 12, top: 12),
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    final entries = [
      SmoothDropdownEntry(content: Text("Created")),
      SmoothDropdownEntry(content: Text("Favored")),
    ];

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: buildUserCard()),
        SliverPadding(
          padding: EdgeInsets.only(top: 24, right: 24.w),
          sliver: SliverToBoxAdapter(
            child: ConstraintLayout(
              width: 200,
              height: 48,
              children: [
                SizedBox(
                  width: 200,
                  height: 48,
                  child: SmoothDropdownMenu(
                    entries: entries,
                    outerColor: themeData().colorScheme.surfaceContainerHigh,
                    entryWidth: 200,
                    entryHeight: 48,
                    overlayOpacity: 1.0,
                    onSelection: (index, entry) {
                      final source = PlaylistSource.values[index];
                      delegate!.playlistSourceNotifier.value = source;
                    },
                  ),
                ).applyConstraint(
                  top: parent.top,
                  bottom: parent.bottom,
                  right: parent.right,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(top: 36, left: 24.w, right: 24.w),
          sliver: ValueListenableBuilder(
            valueListenable: delegate!.profileNotifier,
            builder: (context, profile, _) {
              if (profile == null) {
                return SliverToBoxAdapter(child: LoadingWidget());
              }

              return ValueListenableBuilder(
                valueListenable: delegate!.playlistSourceNotifier,
                builder: (context, source, _) {
                  return PlaylistsGrid(
                    key: ValueKey<PlaylistSource>(source),
                    source: source,
                    userId: profile.userId,
                    onClick: (playlist) {
                      widget.controller.hide();
                      final navigator =
                          GetIt.instance.get<AbstractHomeNavigator>();
                      navigator.navigatePlaylist(playlist);
                    },
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
