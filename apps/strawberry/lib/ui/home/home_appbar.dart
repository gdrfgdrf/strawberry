import 'package:domain/entity/account_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/l10n/localizer.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/ui/abstract_delegate.dart';
import 'package:strawberry/ui/abstract_widget_provider.dart';
import 'package:strawberry/ui/home/home_appbar_delegate.dart';
import 'package:strawberry/ui/profile/profile_sheet_controller.dart';
import 'package:widgets/widgets/next_smooth_image.dart';
import 'package:widgets/widgets/overlay/animated_overlay_entry.dart';
import 'package:widgets/widgets/overlaymenu/auto_overlay_menu.dart';
import 'package:widgets/widgets/overlaymenu/smooth_overlay_menu.dart';
import 'package:widgets/widgets/strawberry_title.dart';

class HomeAppBarProviderFactory<D extends AbstractDelegate>
    extends AbstractWidgetProviderFactory<D, HomeAppBarDelegate> {
  HomeAppBarProviderFactory(super.primaryDelegate);

  @override
  String identifier() => "appbar";

  @override
  AbstractWidgetProvider<D, HomeAppBarDelegate> createImpl(parameter) {
    return HomeAppBarProvider(primaryDelegate);
  }
}

class HomeAppBarProvider<D extends AbstractDelegate>
    extends AbstractWidgetProvider<D, HomeAppBarDelegate> {
  HomeAppBarProvider(super.primaryDelegate);

  @override
  HomeAppBarDelegate createDelegate() {
    return HomeAppBarDelegate();
  }

  @override
  List<VoidCallback> postListeners() {
    return [
      () {
        delegate!.tryFetchAvatar();
      },
    ];
  }

  @override
  List<BlocListener<StateStreamable, dynamic>> blocListeners() {
    return [
      BlocListener(bloc: delegate!.userBloc, listener: (context, state) {}),
    ];
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
              onChanged: (text) {},
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

  @override
  Widget provideImpl(BuildContext context) {
    final profile = GetIt.instance.get<Profile>();
    final overlayMenuController = OverlayMenuController();

    return AppBar(
      backgroundColor: themeData().colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
      title: StrawberryTitle(hero: true),
      centerTitle: true,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: SmoothContainer(
            width: 320,
            height: 40,
            child: SearchAnchor.bar(
              barBackgroundColor: WidgetStatePropertyAll(
                themeData().colorScheme.surfaceContainerLow,
              ),
              viewBackgroundColor: themeData().colorScheme.surfaceContainerLow,
              viewConstraints: BoxConstraints(
                maxWidth: 320,
              ),
              suggestionsBuilder: (context, controller) {
                return [];
              },
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(right: 8),
          child: SmoothContainer(
            width: 40,
            height: 40,
            child: AutoOverlayMenu(
              positionDirection: PositionDirection.downLeft,
              top: Text(profile.nickname, textAlign: TextAlign.center),
              children: [
                OverlayMenuEntry(
                  leadingIcon: Icon(Icons.person, size: 20),
                  content: Text(Localizer.of(context)!.goto_profile_page),
                  onClicked: () {
                    overlayMenuController.hide();
                    GetIt.instance.get<ProfileSheetController>().show(
                      profile.userId,
                    );
                  },
                ),
              ],
              controller: overlayMenuController,
              child: NextSmoothImage.notifier(
                notifier: delegate!.avatarNotifier,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
