import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class CheckTokenGenerator {
  static final UPDATE_FUNC_TIMING = "UPDATE_FUNC_TIMING";
  static final UPDATE_TIME_OFFSET = "UPDATE_TIME_OFFSET";
  static final UPDATE_OPTIONS = "UPDATE_OPTIONS";
  static final base64table2 = [
    'q',
    'X',
    'N',
    'S',
    'C',
    '3',
    'W',
    'T',
    '6',
    '7',
    'd',
    'G',
    'u',
    '4',
    'I',
    's',
    'r',
    'a',
    'K',
    'F',
    'n',
    '5',
    '0',
    'Q',
    '/',
    'f',
    'o',
    't',
    'x',
    'y',
    'p',
    'A',
    '2',
    'O',
    'i',
    '.',
    'g',
    'm',
    'U',
    '+',
    'M',
    'b',
    'J',
    'j',
    'L',
    'k',
    'v',
    'Z',
    'Y',
    'R',
    'w',
    '8',
    '1',
    'e',
    'h',
    '9',
    'B',
    'V',
    'P',
    'H',
    'E',
    'z',
    'c',
    'D',
  ];
  static final base64table = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '+',
    '/',
  ];
  
  static int clamp2int8(int value) {
    if (value < -128) return clamp2int8(128 - (-128 - value));
    if (value >= -128 && value <= 127) return value;
    if (value > 127) return clamp2int8(-129 + value - 127);
    throw Exception("1001");
  }

  static List<int> int32toBytes(int int32value) {
    final result = List<int>.filled(4, 0);
    result[0] = clamp2int8((int32value >>> 24) & 255);
    result[1] = clamp2int8((int32value >>> 16) & 255);
    result[2] = clamp2int8((int32value >>> 8) & 255);
    result[3] = clamp2int8(int32value & 255);
    return result;
  }

  static void copyArray(
    List<int> source,
    int sourceStart,
    List<int> target,
    int targetStart,
    int length,
  ) {
    if (source.isEmpty) return;
    if (source.length < length) throw Exception("1003");
    for (var i = 0; i < length; i++) {
      target[targetStart + i] = source[sourceStart + i];
    }
  }

  static String byte2Hex(int byte) {
    final characters = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
    ];
    return characters[(byte >>> 4) & 15] + characters[byte & 15];
  }

  static String bytes2hex(List<int> bytes) {
    return bytes.map(byte2Hex).join("");
  }

  static String string2hex(String string) {
    final characters = "0123456789abcdef";
    String result = "";
    for (int i = 0; i < string.length; i++) {
      int code = string.codeUnitAt(i);
      result += characters[(code >>> 4) & 15];
      result += characters[code & 15];
    }
    return result;
  }

  static int add32bit(int num1, int num2) {
    int lowSum = (num1 & 0xFFFF) + (num2 & 0xFFFF);
    int highSum = (num1 >> 16) + (num2 >> 16) + (lowSum >> 16);
    return ((highSum & 0xFFFF) << 16) | (lowSum & 0xFFFF);
  }

  static int md5RoundOperation(
    int logicRes,
    int stateA,
    int stateB,
    int msgWord,
    int shift,
    int constant,
  ) {
    logicRes = add32bit(
      add32bit(stateA, logicRes),
      add32bit(msgWord, constant),
    );
    return add32bit((logicRes << shift) | (logicRes >>> (32 - shift)), stateB);
  }

  static int md5FF(
    int stateA,
    int stateB,
    int stateC,
    int stateD,
    int msgWord,
    int shift,
    int finalant,
  ) {
    return md5RoundOperation(
      (stateB & stateC) | (~stateB & stateD),
      stateA,
      stateB,
      msgWord,
      shift,
      finalant,
    );
  }

  static int md5GG(
    int stateA,
    int stateB,
    int stateC,
    int stateD,
    int msgWord,
    int shift,
    int finalant,
  ) {
    return md5RoundOperation(
      (stateB & stateD) | (stateC & ~stateD),
      stateA,
      stateB,
      msgWord,
      shift,
      finalant,
    );
  }

  static int md5HH(
    int stateA,
    int stateB,
    int stateC,
    int stateD,
    int msgWord,
    int shift,
    int constant,
  ) {
    return md5RoundOperation(
      stateC ^ (stateB | ~stateD),
      stateA,
      stateB,
      msgWord,
      shift,
      constant,
    );
  }

  static List<int> hex2bytes(String hex) {
    if (hex.isEmpty) return [];
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      String byteStr = hex.substring(i, i + 2);
      int byteValue = int.parse(byteStr, radix: 16);
      bytes.add(clamp2int8(byteValue));
    }
    return bytes;
  }

  static String base64EncodeChunk(
    List<int> bytes,
    int start,
    int count,
    List<String> table,
    String padding,
  ) {
    int firstByte;
    int secondByte;
    int thirdByte;
    List<String> encodedChunk = [];

    switch (count) {
      case 1:
        firstByte = bytes[start];
        thirdByte = 0;
        encodedChunk.add(table[firstByte >>> 2 & 63]);
        encodedChunk.add(table[(firstByte << 4 & 48) + (thirdByte >>> 4 & 15)]);
        encodedChunk.add(padding);
        encodedChunk.add(padding);
        break;
      case 2:
        firstByte = bytes[start];
        secondByte = bytes[start + 1];
        thirdByte = 0;
        encodedChunk.add(table[firstByte >>> 2 & 63]);
        encodedChunk.add(
          table[(firstByte << 4 & 48) + (secondByte >>> 4 & 15)],
        );
        encodedChunk.add(table[(secondByte << 2 & 60) + (thirdByte >>> 6 & 3)]);
        encodedChunk.add(padding);
        break;
      case 3:
        firstByte = bytes[start];
        secondByte = bytes[start + 1];
        thirdByte = bytes[start + 2];
        encodedChunk.add(table[firstByte >>> 2 & 63]);
        encodedChunk.add(
          table[(firstByte << 4 & 48) + (secondByte >>> 4 & 15)],
        );
        encodedChunk.add(table[(secondByte << 2 & 60) + (thirdByte >>> 6 & 3)]);
        encodedChunk.add(table[thirdByte & 63]);
        break;
      default:
        throw Exception("1010");
    }
    return encodedChunk.join("");
  }

  static String base64(List<int> bytes, List<String> table, String padding) {
    if (bytes.isEmpty) return "";
    final chunkSize = 3;
    List<String> encodedParts = [];
    int byteIdx = 0;

    while (byteIdx < bytes.length) {
      if (byteIdx + chunkSize <= bytes.length) {
        encodedParts.add(
          base64EncodeChunk(bytes, byteIdx, chunkSize, table, padding),
        );
        byteIdx += chunkSize;
      } else {
        int remaining = bytes.length - byteIdx;
        encodedParts.add(
          base64EncodeChunk(bytes, byteIdx, remaining, table, padding),
        );
        break;
      }
    }
    return encodedParts.join("");
  }

  static String defaultBase64(List<int> bytes) {
    return base64(bytes, base64table, "=");
  }

  static String md5hash(String input) {
    int bitLength = input.length * 8;
    int n = (((bitLength + 64) >> 9) + 1) << 4;
    List<int> words = List.filled(n, 0);

    for (int i = 0; i < input.length; i++) {
      int charCode = input.codeUnitAt(i);
      words[i >> 2] |= (charCode & 0xFF) << ((i % 4) * 8);
    }

    words[bitLength >> 5] |= 0x80 << (bitLength % 32);

    int index = ((bitLength + 64) >> 9) << 4 | 14;
    if (index >= words.length) {
      words = List<int>.from(words)
        ..addAll(List.filled(index - words.length + 1, 0));
    }
    words[index] = bitLength;

    int a = 0x67452301;
    int b = 0xEFCDAB89;
    int c = 0x98BADCFE;
    int d = 0x10325476;

    for (int i = 0; i < words.length; i += 16) {
      int aa = a;
      int bb = b;
      int cc = c;
      int dd = d;

      a = md5FF(a, b, c, d, words[i], 7, 0xD76AA478);
      d = md5FF(d, a, b, c, words[i + 1], 12, 0xE8C7B756);
      c = md5FF(c, d, a, b, words[i + 2], 17, 0x242070DB);
      b = md5FF(b, c, d, a, words[i + 3], 22, 0xC1BDCEEE);
      a = md5FF(a, b, c, d, words[i + 4], 7, 0xF57C0FAF);
      d = md5FF(d, a, b, c, words[i + 5], 12, 0x4787C62A);
      c = md5FF(c, d, a, b, words[i + 6], 17, 0xA8304613);
      b = md5FF(b, c, d, a, words[i + 7], 22, 0xFD469501);
      a = md5FF(a, b, c, d, words[i + 8], 7, 0x698098D8);
      d = md5FF(d, a, b, c, words[i + 9], 12, 0x8B44F7AF);
      c = md5FF(c, d, a, b, words[i + 10], 17, 0xFFFF5BB1);
      b = md5FF(b, c, d, a, words[i + 11], 22, 0x895CD7BE);
      a = md5FF(a, b, c, d, words[i + 12], 7, 0x6B901122);
      d = md5FF(d, a, b, c, words[i + 13], 12, 0xFD987193);
      c = md5FF(c, d, a, b, words[i + 14], 17, 0xA679438E);
      b = md5FF(b, c, d, a, words[i + 15], 22, 0x49B40821);

      a = md5GG(a, b, c, d, words[i + 1], 5, 0xF61E2562);
      d = md5GG(d, a, b, c, words[i + 6], 9, 0xC040B340);
      c = md5GG(c, d, a, b, words[i + 11], 14, 0x265E5A51);
      b = md5GG(b, c, d, a, words[i], 20, 0xE9B6C7AA);
      a = md5GG(a, b, c, d, words[i + 5], 5, 0xD62F105D);
      d = md5GG(d, a, b, c, words[i + 10], 9, 0x02441453);
      c = md5GG(c, d, a, b, words[i + 15], 14, 0xD8A1E681);
      b = md5GG(b, c, d, a, words[i + 4], 20, 0xE7D3FBC8);
      a = md5GG(a, b, c, d, words[i + 9], 5, 0x21E1CDE6);
      d = md5GG(d, a, b, c, words[i + 14], 9, 0xC33707D6);
      c = md5GG(c, d, a, b, words[i + 3], 14, 0xF4D50D87);
      b = md5GG(b, c, d, a, words[i + 8], 20, 0x455A14ED);
      a = md5GG(a, b, c, d, words[i + 13], 5, 0xA9E3E905);
      d = md5GG(d, a, b, c, words[i + 2], 9, 0xFCEFA3F8);
      c = md5GG(c, d, a, b, words[i + 7], 14, 0x676F02D9);
      b = md5GG(b, c, d, a, words[i + 12], 20, 0x8D2A4C8A);

      a = md5HH(a, b, c, d, words[i + 5], 4, 0xFFFA3942);
      d = md5HH(d, a, b, c, words[i + 8], 11, 0x8771F681);
      c = md5HH(c, d, a, b, words[i + 11], 16, 0x6D9D6122);
      b = md5HH(b, c, d, a, words[i + 14], 23, 0xFDE5380C);
      a = md5HH(a, b, c, d, words[i + 1], 4, 0xA4BEEA44);
      d = md5HH(d, a, b, c, words[i + 4], 11, 0x4BDECFA9);
      c = md5HH(c, d, a, b, words[i + 7], 16, 0xF6BB4B60);
      b = md5HH(b, c, d, a, words[i + 10], 23, 0xBEBFBC70);
      a = md5HH(a, b, c, d, words[i + 13], 4, 0x289B7EC6);
      d = md5HH(d, a, b, c, words[i], 11, 0xEAA127FA);
      c = md5HH(c, d, a, b, words[i + 3], 16, 0xD4EF3085);
      b = md5HH(b, c, d, a, words[i + 6], 23, 0x04881D05);
      a = md5HH(a, b, c, d, words[i + 9], 4, 0xD9D4D039);
      d = md5HH(d, a, b, c, words[i + 12], 11, 0xE6DB99E5);
      c = md5HH(c, d, a, b, words[i + 15], 16, 0x1FA27CF8);
      b = md5HH(b, c, d, a, words[i + 2], 23, 0xC4AC5665);

      a = md5HH(a, b, c, d, words[i], 6, 0xF4292244);
      d = md5HH(d, a, b, c, words[i + 7], 10, 0x432AFF97);
      c = md5HH(c, d, a, b, words[i + 14], 15, 0xAB9423A7);
      b = md5HH(b, c, d, a, words[i + 5], 21, 0xFC93A039);
      a = md5HH(a, b, c, d, words[i + 12], 6, 0x655B59C3);
      d = md5HH(d, a, b, c, words[i + 3], 10, 0x8F0CCC92);
      c = md5HH(c, d, a, b, words[i + 10], 15, 0xFFEFF47D);
      b = md5HH(b, c, d, a, words[i + 1], 21, 0x85845DD1);
      a = md5HH(a, b, c, d, words[i + 8], 6, 0x6FA87E4F);
      d = md5HH(d, a, b, c, words[i + 15], 10, 0xFE2CE6E0);
      c = md5HH(c, d, a, b, words[i + 6], 15, 0xA3014314);
      b = md5HH(b, c, d, a, words[i + 13], 21, 0x4E0811A1);
      a = md5HH(a, b, c, d, words[i + 4], 6, 0xF7537E82);
      d = md5HH(d, a, b, c, words[i + 11], 10, 0xBD3AF235);
      c = md5HH(c, d, a, b, words[i + 2], 15, 0x2AD7D2BB);
      b = md5HH(b, c, d, a, words[i + 9], 21, 0xEB86D391);

      a = add32bit(a, aa);
      b = add32bit(b, bb);
      c = add32bit(c, cc);
      d = add32bit(d, dd);
    }

    Uint8List output = Uint8List(16);
    ByteData data = ByteData.sublistView(output);
    data.setUint32(0, a, Endian.little);
    data.setUint32(4, b, Endian.little);
    data.setUint32(8, c, Endian.little);
    data.setUint32(12, d, Endian.little);

    return String.fromCharCodes(output);
  }

  static Map<String, dynamic> extendObject(
    Map<String, dynamic> target,
    Map<String, dynamic> source,
  ) {
    source.forEach((key, value) {
      target[key] = value;
    });
    return target;
  }

  static String generateComponent() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final highBits = currentTime ~/ 4294967296;
    final lowBits = currentTime % 4294967296;
    final highBytes = int32toBytes(highBits);
    final lowBytes = int32toBytes(lowBits);
    final timeBytes = List<int>.filled(8, 0);

    copyArray(highBytes, 0, timeBytes, 0, 4);
    copyArray(lowBytes, 0, timeBytes, 4, 4);

    final randomBytes = List<int>.generate(
      8,
      (_) => clamp2int8(Random().nextInt(256)),
    );
    final result = List<int>.filled(timeBytes.length * 2, 0);

    for (int byteIndex = 0; byteIndex < timeBytes.length * 2; byteIndex++) {
      int idx = (byteIndex / 2).floor();
      if (byteIndex % 2 == 0) {
        result[byteIndex] =
            ((randomBytes[idx] & 16) >> 4) |
            ((randomBytes[idx] & 32) >> 3) |
            ((randomBytes[idx] & 64) >> 2) |
            ((randomBytes[idx] & 128) >> 1) |
            ((timeBytes[idx] & 16) >> 3) |
            ((timeBytes[idx] & 32) >> 2) |
            ((timeBytes[idx] & 64) >> 1) |
            (timeBytes[idx] & 128);
      } else {
        result[byteIndex] =
            ((randomBytes[idx] & 1) << 0) |
            ((randomBytes[idx] & 2) << 1) |
            ((randomBytes[idx] & 4) << 2) |
            ((randomBytes[idx] & 8) << 3) |
            ((timeBytes[idx] & 1) << 1) |
            ((timeBytes[idx] & 2) << 2) |
            ((timeBytes[idx] & 4) << 3) |
            ((timeBytes[idx] & 8) << 4);
      }
      result[byteIndex] = clamp2int8(result[byteIndex]);
    }

    final resultHex = bytes2hex(result);
    final resultHex2 = string2hex(
      md5hash('${resultHex}dAWsBhCqtOaNLLJ25hBzWbqWXwiK99Wd'),
    );
    final finalResult = hex2bytes(resultHex2.substring(0, 16));
    return defaultBase64([...finalResult, ...result]);
  }

  static List<int> hexPair2byte(String hexPair) {
    if (hexPair.isEmpty) {
      return [];
    }
    List<int> bytes = [];
    for (int i = 0; i < hexPair.length; i += 2) {
      String byteStr = hexPair.substring(i, i + 2);
      int byteValue = int.parse(byteStr, radix: 16);
      bytes.add(clamp2int8(byteValue));
    }
    return bytes;
  }

  static List<int> string2bytes(String string) {
    if (string.isEmpty) {
      return [];
    }
    String encoded = Uri.encodeComponent(string);
    List<int> bytes = [];

    for (int i = 0; i < encoded.length; i++) {
      if (encoded[i] == '%' && i + 2 < encoded.length) {
        String hexPair = encoded.substring(i + 1, i + 3);
        bytes.add(hexPair2byte(hexPair)[0]);
        i += 2;
      } else {
        bytes.add(clamp2int8(encoded.codeUnitAt(i)));
      }
    }
    return bytes;
  }

  static String encode(String json) {
    if (json.isEmpty) {
      return "";
    }
    final xorKey = [31, 125, -12, 60, 32, 48];
    int keyIdx = 0;

    List<int> jsonBytes = string2bytes(json);
    List<int> bytes = List.filled(jsonBytes.length, 0);

    for (int i = 0; i < jsonBytes.length; i++) {
      bytes[i] = clamp2int8(jsonBytes[i] ^ xorKey[keyIdx % xorKey.length]);
      bytes[i] = clamp2int8(0 - bytes[i]);
      keyIdx++;
    }

    return bytes2hex(bytes);
  }

  static String entrypoint() {
    final component = generateComponent();

    final payload = jsonEncode({"r": 1, "d": "check_token", "b": component});

    return encode(payload);
  }
}

Future<void> main() async {
  final result = await CheckTokenGenerator.entrypoint();
  print(result);
}
