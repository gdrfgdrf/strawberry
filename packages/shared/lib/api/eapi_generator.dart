import 'dart:convert';

import 'package:shared/aes_crypto.dart';

class EapiGenerator {
  static const String cacheKey = ")(13daqP@ssw0rd~";

  static String generateCacheKey(Map<String, dynamic> extra) {
    final keys = extra.keys.toList();
    keys.sort((a, b) => a.codeUnitAt(0).compareTo(b.codeUnitAt(0)));

    final data = {};
    for (final key in keys) {
      data[key] = extra[key];
    }

    final queryString = data.entries
        .map(
          (e) =>
              "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}",
        )
        .join("&");
    final keyBytes = utf8.encode(cacheKey);
    final bytes = utf8.encode(queryString);
    final encrypted = AesCrypto.encrypt(bytes, keyBytes, mode: AesMode.ecb);
    return base64.encode(encrypted);
  }
}
