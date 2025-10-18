
import 'package:data/data.dart';
import 'package:natives/ffi/frb_generated.dart';

class AppInitializer {
  AppInitializer();

  static Future<void> init() async {
    await DataModule.configure();
  }

  static Future<void> initCookieCenter() async {
    await DataModule.configureCookieCenter();
  }

  static Future<void> initIsolatePool() async {
    await DataModule.configureIsolatePool();
  }

  static Future<void> initHive() async {
    await DataModule.configureHive();
  }

}