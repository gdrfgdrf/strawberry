


import 'dart:io';

import 'package:shared/platform_extension.dart';

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

  void _test() {
    if (records.isNotEmpty) {

    }
  }



}