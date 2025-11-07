import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/digests/md5.dart';
import 'package:shared/aes_crypto.dart';
import 'package:shared/string_extension.dart';

void main() {
  // final checkToken = CodeGenerator.generateCheckToken();
  // print(checkToken);

  // final data =
  //     "4E9261B40D00C20360E42D8F50A3CE5B9FAB8640AFA064A4827C6E9BC622376A7CAC515F125D7CC07570D86BE55D0EF7E0240F9EB73B619F5C082CACF8366909CE4E50CD1F5070F247053DD021A18215E12C2BFBE32339EEED15D55AA93C898EAC64E79EA5D7131F3013154BD86BC407544F4AB046F7F44A08A88063C4E594CF39E7CC058BBDC5812F5F2F8EE678C1ADCEFCC749EFA9323A7F72FD9E37FB7F28A0CB27D183F987D6B3A6934297785628E3B2AE0DF2EE978FE27353BE8623FBE77977A3F39DCDEA448D7D05B7EC79A2CC590053C254D5713A3358B595ED45AB886ED6B1A133E6E2D50A5EB5FB33ADE60949BFE8B980A40E8899DE23D9DCFA8E8D917A0BE40ECF760342F9A502BF70D34B4ED67DA4EF736BFE9FC1E86F245C766270C7583BCEDC64F7FD18DA318D28D8F7FF8934478F3C6B4B880EF76F7E8C57AFC46EDE55268CD6A36B7115BDE0080D90E091EE122EBB60097BD4D30C4FA243AD1F40A0AF98E392AF9A8D6D6408778E0ACA194740DB8ABFADACCB0F73799C9776F9012E391901F079E43C720CFE678C09FD88F5BB21510A0B377B3EBC59448B9F110DD465AD048CE84142F293D1528A1F481F975F36F401CC144E9AA9124F575EEF3C085F50876E13E9FD9E988FF1C42BBD1B548CDD53CEF60B2F37478879F45E467836F1600240DB738EDE3C4CF5E402BD1691869C9748C8BA11E3A0121C42995D6212B2DBA7DE1A232DE70DCECDB40B109B27E366CDB3D6CCCE0072236D8A72DEFB33080BA3ADB4EC8361F90D1B20D75F8FA8FA506C662EDE1F914AE36A8C6358F6453D8273272DABB95DDA560C0177B5689C67F704B7775AEE10081183C5BCBF07AC3ACF29ABC25A9AA68FBB764C35FBB328FC95A434BC16DE87C51C647567B9905959180170516C2CCFD9936E9037B391954B9DE5389E71440A60DCEFDA23CF3AE471D38AB499B4C48335853BC6F88EAA55AC074C6DF3B27EA03E5FCDD24E8EFBB2201F53575E7555918A054238C221304909EA1F91F1CC12EEC5321FD81CD25E82E3E706868B0533F7ACCF60AAECE4D9C0F9485747F66996C258D0A89B3E11CA869BDC6AFEF88A9E177993347CF1CC7AB3CF81B54CD0BB0EF5EA38A816F75345438A1A43C9B289AA356E12F1142E427726AC3624A8447C07A4418C3F017A30EC3BD018C9EFA017CADD5E67587E13FA229F1E4A68A9E1655B517B6135FB10B93C72F237A473EBDF434B118672907384C8DDD01F62DD3E190AD5FF9A2789F97C95E48302D499F422BB28262111DDF0";
  //
  // final params = EapiCrypto.paramsDecrypt(data);
  // print(params.path);
  // print(params.json);
  // print(params.hash);

  final data = "BC 31 24 42 91 21 3C 81 FC 32 66 67 8B D3 39 47 68 71 F6 8F 0E 0D 45 C6 73 D3 05 7C 13 6B F0 ED 2B D0 62 B5 CE 7D 0D D9 45 D9 F0 B4 D8 BB FC 04 A2 89 FF FA 14 20 DA 5F B8 E5 29 4D 4A F6 66 49 D9 C1 12 FB 41 24 EE 4F 69 89 12 6E E6 39 68 8D E6 56 A2 74 74 26 B2 16 40 31 3F A1 3C B4 7F 73 C6 12 D7 17 B3 0E DF BB FA 83 B6 BF BA 1B 71 5E 98 26 D5 35 A3 57 86 12 71 A3 80 2C 7D EE 9B C7 A5 C1 BF 01 75 BF A9 65 E9 99 1D 8D 22 24 A3 00 38 FC 04 90 69 F9 5E 4A 04 D3 E9 B4 FD E8 C3 3A DD FB C0 48 80 09 32 BF 56 A6 26 91 F0 EA A3 A6 E3 19 98 59 94 AC E7 23 EB F4 A7 B0 99 0C C1 58 9B A5 48 50 55 65 3E FD 87 8D 86 EE 42 8E 9F 07 6F 7C A2 BB 10 8D 90 5A 79 3D 65 09 F3 C2 05 29 CF A5 93 B9 53 00 BE 73 E5 E6 EA 8E 73 AB 05 4E 72 7E 74 FF 1D 5B B0 3D 3B 7D 9A F8 DD E0 5D 22 DE F5 E8 26 05 C0 EF 18 8F D2 B3 AD 7F F5 D2 7F 07 4D 86 13 E0 90 FC ED 01 89 4D B6 B7 26 CB 88 16 90 0B C4 41 DD 01 3B 63 2D AB C9 30 E5 E3 63 87 3D C6 F5 3A E5 B1 3D 55 69 F5 D2 A3 B6 96 19 3D 8D 96 E3 1B 85 0A EB D6 C9 FC C2 FF 57 4C 9F 86 2F 24 13 E9 8F 31 E8 7E F3 1B 3C 21 D2 72 B3 B3 78 A7 E1 5F 64 FF DF A9 B1 7E BC 01 9A E6 6A 18 5E 93 EB CE 1F 4A 8E 09 9A D3 13 03 C5 5F BE D3 7B 50 AA 75 55 E0 D5 A3 91 65 96 91 F2 8C 60 13 4B 84 CF F5 63 F2 95 29 91 20 91 32 2A 68 1A D4 8D 65 7D 22 F5 6D 4E 83 31 EA 40 1B 5A C7 9D DA 8E 77 EB A4 72 9C 10 8F D5 DA 48 04 35 D7 51 6A A3 B1 02 FB E7 29 6A B0 DB 9E A5 C4 6A D1 2B";
  final data_ = data.replaceAll(" ", "");

  final decrypted = EapiCrypto.dataDecrypt(data_);
  print(decrypted);

  // final string = '''{"e_r":true,"userId":"3288672225","all":"true","header":"{\\"os\\":\\"pc\\",\\"appver\\":\\"2.10.13.202675\\",\\"deviceId\\":\\"B90EBE633AECFFBC47B0677DE17D2EC10837EE27144ED6EFE741\\",\\"requestId\\":\\"12419918\\",\\"clientSign\\":\\"73:D1:B2:72:21:BC@@@32442B892A85D@@@@@@aec85632-106f-09bb-f21e-96943e32dea87602c864e7768dbea7a670e5a0540c78\\",\\"osver\\":\\"Microsoft-Windows-10-Professional-build-16541-64bit\\",\\"Nm-GCore-Status\\":\\"1\\"}"}''';
  // final params = EapiParams("/api/w/v1/user/detail/3288672225", string);
  // final result = EapiCrypto.paramsEncrypt(params);
  // print(result);
}

class EapiParams {
  static final String splitRegex = "-36cd479b6b5-";

  final String path;
  final String json;
  final String hash;

  EapiParams(this.path, this.json)
    : hash = EapiCrypto.md5String("nobody${path}use${json}md5forencrypt");

  static EapiParams fromDecrypted(String decrypted) {
    final split = decrypted.split(splitRegex);
    return EapiParams(split[0], split[1]);
  }
}

class EapiCrypto {
  static final String splitRegex = "-36cd479b6b5-";
  static final String key = "e82ckenh8dichen8";

  const EapiCrypto._();

  static String paramsEncrypt(EapiParams params) {
    final path = params.path;
    final json = params.json;
    final hash = params.hash;
    final text = [path, json, hash].join(splitRegex);

    return base16Encode(
      AesCrypto.encrypt(utf8.encode(text), utf8.encode(key), mode: AesMode.ecb),
    ).toUpperCase();
  }

  static EapiParams paramsDecrypt(String encryptedParams) {
    final message = utf8.encoder.convert(
      AesCrypto.decrypt(
        Uint8List.fromList(encryptedParams.base16decode()),
        utf8.encode(key),
        mode: AesMode.ecb,
      ),
    );
    return EapiParams.fromDecrypted(utf8.decoder.convert(message));
  }

  static String dataEncrypt(String data) {
    return base16Encode(
      AesCrypto.encrypt(utf8.encode(data), utf8.encode(key), mode: AesMode.ecb),
      upperCase: true,
    );
  }

  static String dataDecrypt(String encryptedData) {
    final message = utf8.encoder.convert(
      AesCrypto.decrypt(
        Uint8List.fromList(encryptedData.base16decode()),
        utf8.encode(key),
        mode: AesMode.ecb,
      ),
    );
    return utf8.decoder.convert(message);
  }

  static String md5String(String string) {
    return bytes2hex(md5(utf8.encode(string)));
  }

  static Uint8List md5(Uint8List bytes) {
    return MD5Digest().process(bytes);
  }

  static String base16Encode(List<int> bytes, {bool upperCase = false}) {
    if (bytes.isEmpty) {
      return "";
    }

    const hexChars = '0123456789abcdef';
    final buffer = StringBuffer();

    for (final byte in bytes) {
      if (byte < 0 || byte > 255) {
        throw ArgumentError("Invalid byte value: $byte. Bytes must be 0-255.");
      }

      buffer.write(hexChars[byte >> 4]);
      buffer.write(hexChars[byte & 0x0F]);
    }

    return upperCase ? buffer.toString().toUpperCase() : buffer.toString();
  }

  static String bytes2hex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
