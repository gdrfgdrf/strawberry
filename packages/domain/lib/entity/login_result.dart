import 'dart:convert';

import 'package:hive_ce/hive.dart';

import 'account_entity.dart';
import 'package:domain/hives.dart';

/// 800: 过期
/// 801: 等待扫码
/// 802: 授权中
/// 803: 授权成功
class QrCodeResult {
  final int code;
  final String message;

  final String? nickname;
  final String? avatarUrl;

  const QrCodeResult(this.code, this.message, this.nickname, this.avatarUrl);

  bool isExpired() {
    return code == 800;
  }

  bool isWaiting() {
    return code == 801;
  }

  bool isAuthorizing() {
    return code == 802;
  }

  bool isAuthorized() {
    return code == 803;
  }

  bool isError() {
    return code != 800 && code != 801 && code != 802 && code != 803;
  }

  bool needNextCheck() {
    return isWaiting() || isAuthorizing();
  }

  static QrCodeResult parseJson(String string) {
    final json = jsonDecode(string);
    return QrCodeResult(
      json["code"] ?? -1,
      json["message"] ?? "",
      json["nickname"],
      json["avatarUrl"],
    );
  }
}

@HiveType(typeId: HiveTypes.loginResultId)
class LoginResult {
  @HiveField(0)
  final Account account;
  @HiveField(1)
  final Profile profile;

  const LoginResult(this.account, this.profile);

  static LoginResult parseJson(String string) {
    final json = jsonDecode(string);

    return LoginResult(
      Account.parseJson(jsonEncode(json["account"] ?? {})),
      Profile.parseJson(jsonEncode(json["profile"] ?? {})),
    );
  }
}
