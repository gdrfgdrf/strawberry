import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:strawberry/play/songbar/song_bar_controller.dart';
import 'package:strawberry/ui/profile/profile_page.dart';

class ProfileSheetController {
  final logger = GetIt.instance.get<DartStrawberryLogger>();

  final int userId;
  final BuildContext context;
  bool shown = false;

  ProfileSheetController(this.userId, this.context);

  void show() {
    logger.info("showing profile sheet, id: $userId");

    SongBarController.getOrCreate().hide();

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
        shown = true;
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ProfilePage(controller: this),
        );
      },
    ).then((_) {
      shown = false;
      SongBarController.getOrCreate().show(context);
    });
  }

  void hide() {
    if (!shown) {
      return;
    }
    logger.info("hiding profile sheet, id: $userId");
    Navigator.pop(context);
  }
}
