import 'dart:convert';
import 'dart:math';

import 'package:shared/api/builtin_device_ids.dart';

class Client {
  String appVer;

  Client(this.appVer);

  String toJson() {
    return jsonEncode({"app-ver": appVer});
  }

  static Client parseJson(String string) {
    final json = jsonDecode(string);
    return Client(json["app-ver"] ?? "2.10.13.202675");
  }
}

class ClientSign {
  static final String firstSplit = "@@@";
  static final String secondSplit = "@@@@@@";

  /// XX:XX:XX:XX:XX:XX
  String mac;

  /// XXXXXXXXXXXXX(13)
  String deviceIdentifier;

  // xxxxxxxx(8)-xxxx-xxxx-xxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(44)
  String hash;

  ClientSign(this.mac, this.deviceIdentifier, this.hash);

  String build() {
    return "$mac$firstSplit$deviceIdentifier$secondSplit$hash";
  }

  String toJson() {
    return jsonEncode({
      "mac": mac,
      "device-identifier": deviceIdentifier,
      "hash": hash,
    });
  }

  static ClientSign generate() {
    final mac = CodeGenerator.generateMac();
    final deviceIdentifier = CodeGenerator.generateDeviceIdentifier();
    final hash = CodeGenerator.generateDeviceUuid();
    return ClientSign(mac, deviceIdentifier, hash);
  }

  static ClientSign parseJson(String string) {
    final json = jsonDecode(string);

    return ClientSign(
      json["mac"] ?? CodeGenerator.generateMac(),
      json["device-identifier"] ?? CodeGenerator.generateDeviceIdentifier(),
      json["hash"] ?? CodeGenerator.generateDeviceUuid(),
    );
  }
}

class Device {
  String osVer;
  String deviceId;

  Device(this.osVer, this.deviceId);

  String toJson() {
    return jsonEncode({"os-ver": osVer, "device-id": deviceId});
  }

  static Device parseJson(String string) {
    final json = jsonDecode(string);
    return Device(
      json["os-ver"] ?? "Microsoft-Windows-10-Professional-build-16541-64bit",
      json["device-id"] ?? CodeGenerator.generateDeviceId(),
    );
  }
}

class CodeFetcher {
  static String fetchOsVer() {
    return "";
  }
}

class CodeGenerator {
  static String generateRequestId() {
    final random = Random();
    final buffer = StringBuffer();

    for (int i = 0; i < 8; i++) {
      final int group = random.nextInt(256);
      buffer.write("$group");
    }

    return buffer.toString().substring(0, 8);
  }

  static String generateDeviceId() {
    return BuiltInDeviceIds.randomId();
    // final random = Random();
    // final buffer = StringBuffer();
    //
    // for (int i = 0; i < 52; i++) {
    //   final int group = random.nextInt(256);
    //   final String generated = group.toRadixString(16).padLeft(2, '0');
    //   buffer.write(generated.substring(1));
    // }
    //
    // return buffer.toString().toUpperCase();
  }

  static String generateMac() {
    final random = Random();
    final buffer = StringBuffer();

    for (int i = 0; i < 6; i++) {
      final int group = random.nextInt(256);
      final String hexGroup =
          group.toRadixString(16).padLeft(2, '0').toUpperCase();

      buffer.write(hexGroup);
      if (i < 5) {
        buffer.write(':');
      }
    }

    return buffer.toString();
  }

  static String generateDeviceIdentifier() {
    final random = Random();
    final buffer = StringBuffer();

    for (int i = 0; i < 13; i++) {
      final int group = random.nextInt(256);
      final String generated =
          group.toRadixString(16).padLeft(2, '0').toUpperCase();
      buffer.write(generated.substring(1));
    }

    return buffer.toString().substring(0, 13);
  }

  static String generateDeviceUuid() {
    final random = Random();
    final buffer = StringBuffer();

    for (int i = 0; i < 8; i++) {
      final int group = random.nextInt(256);
      final String generated = group.toRadixString(16).padLeft(2, '0');
      buffer.write(generated.substring(1));
    }
    buffer.write("-");

    for (int i = 0; i < 4; i++) {
      final int group = random.nextInt(256);
      final String generated = group.toRadixString(16).padLeft(2, '0');
      buffer.write(generated.substring(1));
    }
    buffer.write("-");

    for (int i = 0; i < 4; i++) {
      final int group = random.nextInt(256);
      final String generated = group.toRadixString(16).padLeft(2, '0');
      buffer.write(generated.substring(1));
    }
    buffer.write("-");

    for (int i = 0; i < 4; i++) {
      final int group = random.nextInt(256);
      final String generated = group.toRadixString(16).padLeft(2, '0');
      buffer.write(generated.substring(1));
    }
    buffer.write("-");

    for (int i = 0; i < 44; i++) {
      final int group = random.nextInt(256);
      final String generated = group.toRadixString(16).padLeft(2, '0');
      buffer.write(generated.substring(1));
    }

    return buffer.toString();
  }
}
