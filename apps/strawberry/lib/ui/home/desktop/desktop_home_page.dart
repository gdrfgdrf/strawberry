import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:strawberry/app_config.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/home/home_page_delegate.dart';
import 'package:strawberry/ui/playing/playing_page_controller.dart';
import 'package:strawberry/ui/router/home_router.dart';

import '../../../play/songbar/desktop_song_bar_controller.dart';

class DesktopHomePage extends AbstractUiWidget {
  @override
  State<StatefulWidget> createState() => DesktopHomePageState();
}

class DesktopHomePageState
    extends AbstractUiWidgetState<DesktopHomePage, HomePageDelegate> {
  @override
  HomePageDelegate createDelegate() {
    return HomePageDelegate();
  }

  @override
  Widget buildContent(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DesktopPlayingPageController.prepare(context);
      DesktopSongBarController.prepare();
      final songBarController = GetIt.instance.get<DesktopSongBarController>();
      songBarController.show(context);
    });

    return Scaffold(
      appBar: delegate!.getWidget("appbar") as PreferredSizeWidget,
      body: Navigator(
        key: AppConfig.homeNavigatorKey,
        onGenerateRoute: GetIt.instance.get<HomeRouter>().getRouter().generator,
      ),
    );
  }
}
