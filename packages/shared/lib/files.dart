import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/digests/sha256.dart';

class Files {
  static Future<String> sha256(List<int> bytes) async {
    return compute(<List, String>(bytes) {
      final digest = SHA256Digest();
      final output = Uint8List(digest.digestSize);
      digest.update(Uint8List.fromList(bytes), 0, bytes.length);
      digest.doFinal(output, 0);
      return bytesToHex(output);
    }, bytes);
  }

  static String bytesToHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
