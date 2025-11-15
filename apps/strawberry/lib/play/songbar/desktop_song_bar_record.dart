


import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/play/songbar/desktop_song_bar_controller.dart';

class DesktopSongBarRecorder {
  final records = <String>[];

  void record(String name) {
    if (!PlatformExtension.isDesktop) {
      return;
    }
    records.add(name);
    _test();
  }

  void dismiss(String name) {
    if (!PlatformExtension.isDesktop) {
      return;
    }
    records.remove(name);
    _test();
  }

  void _test() async {
    final controller = GetIt.instance.get<DesktopSongBarController>();

    final shown = await controller.shown();
    if (records.isNotEmpty) {
      if (shown) {
        controller.hide();
      }
    } else {
      if (!shown) {
        controller.show();
      }
    }
  }

  static void prepare() {
    if (!PlatformExtension.isDesktop) {
      return;
    }
    if (!GetIt.instance.isRegistered<DesktopSongBarRecorder>()) {
      final recorder = DesktopSongBarRecorder();
      GetIt.instance.registerSingleton<DesktopSongBarRecorder>(recorder);
    }
  }

}