import 'dart:convert';

import 'package:natives/wrap/strawberry_logger_wrapper.dart';

class GeneralConfig {
  int lastLoginId;
  String userAgent;
  Map<String, dynamic> customHeaders = {};
  List<int> logImmediateFlush = [];
  List<int> logEnabledLevels = [];

  GeneralConfig(
    this.lastLoginId,
    this.userAgent,
    this.customHeaders,
    this.logImmediateFlush,
    this.logEnabledLevels,
  );

  String toJson() {
    return jsonEncode({
      "last-login-id": lastLoginId,
      "user-agent": userAgent,
      "custom-headers": customHeaders,
      "log-immediate-flush": logImmediateFlush,
      "log-enabled-levels": logEnabledLevels,
    });
  }

  static GeneralConfig parseJson(String string) {
    final json = jsonDecode(string);
    return GeneralConfig(
      json["last-login-id"] ?? -1,
      json["user-agent"] ?? "",
      json["custom-headers"] ?? {},
      ((json["log-immediate-flush"] ?? DartLogLevel.runtime) as List<dynamic>)
          .map((a) => a as int)
          .toList(),
      ((json["log-enabled-levels"] ?? DartLogLevel.runtime) as List<dynamic>)
          .map((a) => a as int)
          .toList(),
    );
  }
}
