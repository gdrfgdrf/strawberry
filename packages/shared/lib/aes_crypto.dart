import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/block/modes/ecb.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'package:pointycastle/random/fortuna_random.dart';

enum AesMode { ecb, cbc }

class AesCrypto {
  const AesCrypto._();

  static String encryptString(
    String plainText,
    String key, {
    AesMode mode = AesMode.cbc,
    String? iv,
    int? blockSize,
  }) {
    final keyBytes = utf8.encode(key);

    Uint8List? ivBytes;
    if (_modeRequiresIV(mode)) {
      ivBytes = iv != null ? utf8.encode(iv) : _generateRandomBytes(16);
    }

    final cipher = _createCipher(true, keyBytes, ivBytes, mode);

    final plainBytes = utf8.encode(plainText);
    final encryptedBytes = cipher.process(plainBytes);

    return base64Encode(encryptedBytes);
  }

  static Uint8List encrypt(
    Uint8List plainText,
    Uint8List key, {
    AesMode mode = AesMode.cbc,
    Uint8List? iv,
    int? blockSize,
  }) {
    Uint8List? ivBytes;
    if (_modeRequiresIV(mode)) {
      ivBytes = iv ?? _generateRandomBytes(16);
    }

    final cipher = _createCipher(true, key, ivBytes, mode);
    final encryptedBytes = cipher.process(plainText);
    return encryptedBytes;
  }

  static String decryptString(
    String encrypted,
    String key, {
    AesMode mode = AesMode.cbc,
    int? blockSize,
  }) {
    final bytes = base64Decode(encrypted);
    final keyBytes = utf8.encode(key);
    return decrypt(bytes, keyBytes);
  }

  static String decrypt(
    Uint8List encrypted,
    Uint8List key, {
    AesMode mode = AesMode.cbc,
    int? blockSize,
  }) {
    Uint8List? ivBytes;
    Uint8List encryptedBytes;

    if (_modeRequiresIV(mode)) {
      ivBytes = encrypted.sublist(0, 16);
      encryptedBytes = encrypted.sublist(16);
    } else {
      encryptedBytes = encrypted;
    }

    final cipher = _createCipher(false, key, ivBytes, mode);

    final decryptedBytes = cipher.process(encryptedBytes);
    return utf8.decode(decryptedBytes);
  }

  static dynamic _createCipher(
    bool forEncryption,
    Uint8List key,
    Uint8List? iv,
    AesMode mode,
  ) {
    switch (mode) {
      case AesMode.ecb:
        final cipher = PaddedBlockCipherImpl(
          PKCS7Padding(),
          ECBBlockCipher(AESEngine()),
        );
        final params = PaddedBlockCipherParameters(KeyParameter(key), null);
        cipher.init(forEncryption, params);
        return cipher;

      case AesMode.cbc:
        final cipher = PaddedBlockCipherImpl(
          PKCS7Padding(),
          CBCBlockCipher(AESEngine()),
        );
        final params = PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(key), iv!),
          null,
        );
        cipher.init(forEncryption, params);
        return cipher;
    }
  }

  static bool _modeRequiresIV(AesMode mode) {
    return mode != AesMode.ecb;
  }

  static Uint8List _generateRandomBytes(int length) {
    final secureRandom = FortunaRandom();

    final seedSource = List<int>.generate(
      32,
      (i) => Random.secure().nextInt(256),
    );
    secureRandom.seed(KeyParameter(Uint8List.fromList(seedSource)));

    return secureRandom.nextBytes(length);
  }
}
