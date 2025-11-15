import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/play/songbar/desktop_song_bar_controller.dart';
import 'package:strawberry/ui/playing/desktop/desktop_playing_page.dart';
import 'package:uuid/v4.dart';

import '../../play/songbar/desktop_song_bar_record.dart';

class DesktopPlayingPageController {
  final BuildContext context;

  String? id;

  DesktopPlayingPageController(this.context);

  void show() {
    if (id != null) {
      return;
    }

    final recorder = GetIt.instance.get<DesktopSongBarRecorder>();
    id = UuidV4().generate();
    recorder.record("playing-page-$id");

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
      recorder.dismiss("playing-page-$id");
      id = null;
    });
  }

  void hide() {
    if (id == null) {
      return;
    }
    Navigator.pop(context);
  }

  static void prepare(BuildContext context) {
    if (!PlatformExtension.isDesktop) {
      return;
    }
    if (!GetIt.instance.isRegistered<DesktopPlayingPageController>()) {
      final playingPageController = DesktopPlayingPageController(context);
      GetIt.instance.registerSingleton<DesktopPlayingPageController>(
        playingPageController,
      );
    }
  }
}
