import 'dart:convert';

import 'package:data/http/url/api_url_provider.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/api/check_token_generator.dart';
import 'package:shared/api/device.dart';
import 'package:shared/api/eapi.dart';
import 'package:shared/api/netease_dll_crypto.dart';
import 'package:shared/configuration/desktop_config.dart';

class UrlProviderImpl extends UrlProvider {
  @override
  String get baseUrl => "https://music.163.com";

  /// normal body: {"e_r": true, "header":"{\"os\":\"pc\",\"appver\":\"xxx\",\"deviceId\":\"xxx\",\"requestId\":\"xxx\",\"clientSign\":\"xxx\",\"osver\":\"xxx\"}"}
  dynamic buildBody({
    Map<String, dynamic>? extra,
    Map<String, dynamic>? extraHeader,
  }) {
    final resultMap = <String, dynamic>{};
    if (extra != null) {
      resultMap.addAll(extra);
    }
    resultMap["e_r"] = true;

    final desktopConfig = GetIt.instance.get<DesktopConfig>();
    final device = desktopConfig.device;
    final client = desktopConfig.client;
    final clientSign = desktopConfig.clientSign;

    Map<String, dynamic> headerMap = {
      "os": "pc",
      "appver": client.appVer,
      "deviceId": device.deviceId,
      "requestId": CodeGenerator.generateRequestId(),
      "clientSign": clientSign.build(),
      "osver": device.osVer,
    };

    if (extraHeader != null) {
      headerMap.addAll(extraHeader);
    }

    /// header 参数需要添加反斜杠转义
    resultMap["header"] = jsonEncode(headerMap);

    return jsonDecode(jsonEncode(resultMap));
  }

  /// normal body: {"e_r": true, "type": "xxx", "header":"{\"os\":\"pc\",\"appver\":\"xxx\",\"deviceId\":\"xxx\",\"requestId\":\"xxx\",\"clientSign\":\"xxx\",\"osver\":\"xxx\"}"}
  dynamic buildTypedBody(
    String type, {
    Map<String, dynamic>? extra,
    Map<String, dynamic>? extraHeader,
  }) {
    final result = buildBody(extra: extra, extraHeader: extraHeader);
    result["type"] = type;

    return result;
  }

  @override
  Endpoint registerAnonimous({required String deviceId}) {
    final encoded = NeteaseDllCrypto.encodeAnonymousId(deviceId);

    return Endpoint.get(
      path: "/api/register/anonimous",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: false,
      requiresDecryption: false,
      queryParams: {"username": encoded},
    );
  }

  @override
  Endpoint userLoginEmail({required String email, required String password}) {
    final regex = RegExp(
      "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$",
    );

    return Endpoint.post(
      path: "/eapi/w/login",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      queryParams: {"email": email, "password": password},
      validator: (params) {
        if (email.isEmpty) {
          return false;
        }
        if (password.isEmpty) {
          return false;
        }
        if (!regex.hasMatch(email)) {
          return false;
        }
        return true;
      },
    );
  }

  @override
  Endpoint userLoginCellphoneDesktop({
    required String countryCode,
    required String appVer,
    required String deviceId,
    required String requestId,
    required ClientSign clientSign,
    required String osVer,
    required String cellphone,
    required String password,
  }) {
    final checkToken = CheckTokenGenerator.entrypoint();

    return Endpoint.post(
      path: "/eapi/w/login/cellphone",
      eapiPath: "/api/w/login/cellphone",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      headers: {"X-antiCheatToken": checkToken},
      body: {
        buildTypedBody(
          "1",
          extra: {
            "password": EapiCrypto.md5String(password),
            "remember": "true",
            "https": "true",
            "checkToken": checkToken,
            "phone": cellphone,
            "countrycode": countryCode,
          },
          extraHeader: {"Nm-GCore-Status": "1", "X-antiCheatToken": checkToken},
        ),
      },
    );
  }

  @override
  Endpoint userLoginQrCodeGetUniKey() {
    return Endpoint.post(
      path: "/eapi/login/qrcode/unikey",
      eapiPath: "/api/login/qrcode/unikey",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildTypedBody("3"),
    );
  }

  @override
  Endpoint userLoginQrCode(String uniKey) {
    return Endpoint.post(
      path: "/eapi/login/qrcode/client/login",
      eapiPath: "/api/login/qrcode/client/login",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildTypedBody(
        "3",
        extra: {"key": uniKey},
        extraHeader: {"Nm-GCore-Status": "1"},
      ),
    );
  }

  @override
  Endpoint refreshToken_Type1() {
    final checkToken = CheckTokenGenerator.entrypoint();

    return Endpoint.post(
      path: "/eapi/login/token/refresh",
      eapiPath: "/api/login/token/refresh",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      headers: {"X-antiCheatToken": checkToken},
      body: buildBody(
        extra: {"checkToken": checkToken},
        extraHeader: {"X-antiCheatToken": checkToken},
      ),
    );
  }

  @override
  Endpoint refreshToken_Type2() {
    return Endpoint.post(
      path: "/eapi/middle/account/token/refresh",
      eapiPath: "/api/middle/account/token/refresh",
      baseUrl: "https://interface3.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildBody(extraHeader: {"Nm-GCore-Status": "1"}),
    );
  }

  @override
  Endpoint userDetail_Type1(int userId) {
    return Endpoint.post(
      path: "/eapi/w/v1/user/detail/:userId",
      eapiPath: "/api/w/v1/user/detail/$userId",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      pathParams: {"userId": userId},
      body: buildBody(
        extra: {"userId": userId, "all": "true"},
        extraHeader: {"Nm-GCore-Status": "1"},
      ),
    );
  }

  @override
  Endpoint userDetail_Type2() {
    return Endpoint.post(
      path: "/eapi/w/nuser/account/get",
      eapiPath: "/api/w/nuser/account/get",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildBody(),
    );
  }

  @override
  Endpoint playlists(int userId) {
    return Endpoint.post(
      path: "/eapi/user/playlist",
      eapiPath: "/api/user/playlist",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildBody(extra: {"offset": "0", "limit": "1000", "uid": userId}),
    );
  }

  @override
  Endpoint playlistQuery(int id, int songCount) {
    return Endpoint.post(
      path: "/eapi/v6/playlist/detail",
      eapiPath: "/api/v6/playlist/detail",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildBody(extra: {"id": id, "t": "-1", "n": songCount, "s": "0"}),
    );
  }

  @override
  Endpoint songDetails(List<int> ids) {
    List<Map<String, int>> combinedIds = [];

    for (final id in ids) {
      combinedIds.add({"id": id, "v": 0});
    }

    return Endpoint.post(
      path: "/eapi/v3/song/detail",
      eapiPath: "/api/v3/song/detail",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildBody(
        extra: {"c": jsonEncode(combinedIds)},
        extraHeader: {"Nm-GCore-Status": "1"},
      ),
    );
  }

  /// 正常情况 encodeType 为 mp3。若 effects 包含 "dolby"，则 encodeType 为 mp4
  @override
  Endpoint songPlayerFiles(
    List<int> ids,
    SongQualityLevel level, {
    List<String> effects = const [],
    String? encodeType,
  }) {
    List<String> stringIds = ids.map((id) => id.toString()).toList();
    String actualEncodeType = "mp3";

    if (encodeType != null) {
      actualEncodeType = encodeType;
    } else {
      actualEncodeType = effects.contains("dolby") ? "mp4" : "mp3";
    }

    Map<String, String> extra;
    if (effects.isEmpty) {
      extra = {
        "ids": jsonEncode(stringIds),
        "level": level.name,
        "encodeType": actualEncodeType,
      };
    } else {
      extra = {
        "ids": jsonEncode(stringIds),
        "level": level.name,
        "effects": jsonEncode(effects),
        "encodeType": actualEncodeType,
      };
    }

    return Endpoint.post(
      path: "/eapi/song/enhance/player/url/v1",
      eapiPath: "/api/song/enhance/player/url/v1",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildBody(extra: extra, extraHeader: {"Nm-GCore-Status": "1"}),
    );
  }

  @override
  Endpoint songLyric(int id) {
    return Endpoint.post(
      path: "/eapi/song/lyric",
      eapiPath: "/api/song/lyric",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildBody(
        extra: {
          "os": "pc",
          "id": id.toString(),
          "lv": "-1",
          "kv": "-1",
          "tv": "-1",
          "rv": "-1",
          "yv": "1",
          "showRole": "true",
          "cp": "true",
        },
        extraHeader: {"Nm-GCore-Status": "1"},
      ),
    );
  }

  @override
  Endpoint songLike(int id, bool like) {
    final checkToken = CheckTokenGenerator.entrypoint();

    return Endpoint.post(
      path: "/eapi/song/like",
      eapiPath: "/api/song/like",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildBody(
        extra: {
          "trackId": "$id",
          "userid": "0",
          "like": "$like",
          "hotKey": "undefined",
          "checkToken": checkToken,
        },
        extraHeader: {"Nm-GCore-Status": "1", "X-antiCheatToken": checkToken},
      ),
    );
  }

  @override
  Endpoint searchSuggestion(String keyword) {
    return Endpoint.post(
      path: "/eapi/search/suggest/keyword/get",
      eapiPath: "/api/search/suggest/keyword/get",
      baseUrl: "https://interface.music.163.com",
      requiresEncryption: true,
      requiresDecryption: true,
      body: buildBody(
        extra: {"keyword": keyword},
        extraHeader: {"Nm-GCore-Status": "1"},
      ),
    );
  }
}
