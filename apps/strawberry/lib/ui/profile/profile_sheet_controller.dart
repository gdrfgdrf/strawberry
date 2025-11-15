import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/play/songbar/desktop_song_bar_controller.dart';
import 'package:strawberry/play/songbar/desktop_song_bar_record.dart';
import 'package:strawberry/ui/profile/profile_page.dart';
import 'package:uuid/v4.dart';

class ProfileSheetController {
  final logger = GetIt.instance.get<DartStrawberryLogger>();

  final BuildContext context;

  String? id;

  ProfileSheetController(this.context);

  void show(int userId) {
    if (id != null) {
      return;
    }
    final recorder = GetIt.instance.get<DesktopSongBarRecorder>();
    id = UuidV4().generate();

    recorder.record("profile-sheet-$id");

    logger.info("showing profile sheet, id: $userId");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      sheetAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 300)
      ),
      constraints: BoxConstraints(
        minWidth: 800,
        maxWidth: 800
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ProfilePage(userId: userId),
        );
      },
    ).then((_) {
      recorder.dismiss("profile-sheet-$id");
      id = null;
    });
  }

  void hide() {
    if (id == null) {
      return;
    }
    logger.info("hiding profile sheet");
    Navigator.pop(context);
  }

  static void prepare(BuildContext context) {
    if (!PlatformExtension.isDesktop) {
      return;
    }
    if (!GetIt.instance.isRegistered<ProfileSheetController>()) {
      final playingPageController = ProfileSheetController(context);
      GetIt.instance.registerSingleton<ProfileSheetController>(
        playingPageController,
      );
    }
  }
}
