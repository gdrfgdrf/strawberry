import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:domain/entity/account_entity.dart';
import 'package:domain/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/configuration/general_config.dart';
import 'package:shared/platform_extension.dart';
import 'package:window_manager/window_manager.dart';

class LoginCenter {
  static void success(BuildContext context) async {
    if (!GetIt.instance.isRegistered<Account>() ||
        !GetIt.instance.isRegistered<Profile>()) {
      throw ArgumentError("one of account and profile is not configured");
    }

    final profile = GetIt.instance.get<Profile>();
    final id = profile.userId;

    final generalConfig = GetIt.instance.get<GeneralConfig>();
    generalConfig.lastLoginId = id;

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}${Platform.pathSeparator}strawberry_data";
    final pathDirectory = Directory(path);
    if (!await pathDirectory.exists()) {
      await pathDirectory.create();
    }
    final generalConfigFile = File("$path/general_config.json");
    if (!await generalConfigFile.exists()) {
      await generalConfigFile.create();
    }
    generalConfigFile.writeAsString(generalConfig.toJson());

    if (PlatformExtension.isDesktop) {
      await Future.wait([
        WindowManager.instance.setSize(Size(1178, 746)),
        WindowManager.instance.setMinimumSize(Size(1178, 746)),
      ]);
    }

    final navigator = GetIt.instance.get<AbstractMainNavigator>();
    navigator.navigateHome();
  }
}
