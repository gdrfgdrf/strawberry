import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:pointycastle/digests/sha256.dart';

class Files {
  static Future<String> sha256(List<int> bytes) async {
    final digest = SHA256Digest();
    final output = Uint8List(digest.digestSize);
    digest.update(Uint8List.fromList(bytes), 0, bytes.length);
    digest.doFinal(output, 0);
    return bytesToHex(output);
  }

  static String bytesToHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}