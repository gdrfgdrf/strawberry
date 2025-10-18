
import 'dart:io';

class PlatformExtension {
  static bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;
}