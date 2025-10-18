import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:strawberry/play/songbar/song_bar_controller.dart';
import 'package:strawberry/ui/playing/desktop/desktop_playing_page.dart';

class DesktopPlayingPageController {
  final BuildContext context;

  const DesktopPlayingPageController(this.context);

  void show() {
    SongBarController.getOrCreate().hide();

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
      SongBarController.getOrCreate().show(context);
    });
  }
}
