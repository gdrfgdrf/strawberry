import 'dart:convert';

import 'package:shared/api/device.dart';

class DesktopConfig {
  ClientSign clientSign;
  Client client;
  Device device;

  DesktopConfig(this.clientSign, this.client, this.device);

  String toJson() {
    return jsonEncode({
      "client-sign": jsonDecode(clientSign.toJson()),
      "client": jsonDecode(client.toJson()),
      "device": jsonDecode(device.toJson()),
    });
  }

  static DesktopConfig parseJson(String string) {
    final json = jsonDecode(string);

    return DesktopConfig(
      ClientSign.parseJson(jsonEncode(json["client-sign"] ?? {})),
      Client.parseJson(jsonEncode(json["client"] ?? {})),
      Device.parseJson(jsonEncode(json["device"] ?? {})),
    );
  }
}
