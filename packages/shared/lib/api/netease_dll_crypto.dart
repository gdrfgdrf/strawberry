
import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/digests/md5.dart';
import 'package:shared/api/device.dart';

class NeteaseDllCrypto {
  static final String idXorKey = "3go8&\$8*3*3h0k(2)2";

  static String encodeAnonymousId(String deviceId) {
    final keyBytes = Uint8List.fromList(idXorKey.codeUnits);
    final inputBytes = Uint8List.fromList(utf8.encode(deviceId));
    final result = Uint8List(inputBytes.length);

    for (int i = 0; i < inputBytes.length; i++) {
      result[i] = inputBytes[i] ^ keyBytes[i % keyBytes.length];
    }

    final md5 = MD5Digest();
    final digest = md5.process(result);

    final encoded = base64.encode(digest);

    return base64.encode(utf8.encode("$deviceId ${encoded.replaceAll("/", "_")}"));
  }




}