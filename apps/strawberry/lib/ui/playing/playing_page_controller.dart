import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/play/songbar/desktop_song_bar_controller.dart';
import 'package:strawberry/ui/playing/desktop/desktop_playing_page.dart';

class DesktopPlayingPageController {
  final BuildContext context;

  const DesktopPlayingPageController(this.context);

  void show() {
    final screenSize = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      sheetAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 300),
      ),
      constraints: BoxConstraints(
        minWidth: screenSize.width,
        minHeight: screenSize.height,
      ),
      builder: (context) {
        return DesktopPlayingPage(audioPlayer: GetIt.instance.get());
      },
    ).then((_) {

    });
  }

  static void prepare(BuildContext context) {
    if (!PlatformExtension.isDesktop) {
      return;
    }
    final playingPageController = DesktopPlayingPageController(context);
    if (!GetIt.instance.isRegistered<DesktopPlayingPageController>()) {
      GetIt.instance.registerSingleton<DesktopPlayingPageController>(
        playingPageController,
      );
    }
  }
}
