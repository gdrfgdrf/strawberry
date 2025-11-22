import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/digests/md5.dart';
import 'package:shared/aes_crypto.dart';
import 'package:shared/string_extension.dart';

void main() {
  // final checkToken = CodeGenerator.generateCheckToken();
  // print(checkToken);

  // final data =
  //     "0BD8BB39A78692F1744DEFF63EBC30F736935243CCC31B0CC4BB94588F4A293F4A07D3D60D7A91A881157432C68809224DCE2A2FC08172F988BF617B8224850A25F96A35401F212A6A5E0348885A5B501BEE5A3CB386108C9D174AC5545A3A3D884121C55BBC740CD28370D006F5661F4A1E7D3336D3DC7962DB6FEFAFAC4D2130F2912DD4B7716AF1232FFF8DFE68CC6938AD9B38E451B678561419F8D0E324462EE3AF676D09A9087B13263A9C7EBCD12CBC562E4BA48998412B4B3AACC991021716313FC2F2E4B06CA6E8EBFEC475B8D1875B3C2F1CA11F72C10EB79138B535142C45FCCE6DF6BDC4D55F36B5CCC8B088DC0C6B5620DD9BB8A917CB166602358E8EC4BB312F47D31D1A00C01413A288BB79B9B857C9D8D959C37CA7BDFCAE0F0F36A36F6A12A4744D38B6E7248D37AC35AFECD0B7F5C2EA4AB25FBF81A26630E8CE617869C52F03E70B06838D94E9A6B2A34B5A2DA314F932982A10477299001486F6D7C1A1221632A5C9FED5740FD80C73F48332192DA3FF942D00ECD2C474BE344D4863D9E217C08AA281CE57EF68C6D55D39379FA7593FC952FA2CC86883EFA25BE979CDA0FF69786EC36D5262AB9B22A1055838D62F4CE8B97B37512C4537AF5DB85E45D6093F331D6B046AB116F34FA477B2995D933731A696A30E1BA8BF871D16651E1BAF8E1085EDDA8B6A5597AFDC46A686A9A5476AD9BC8BE994589586494C0B08B8A5E29089B3082EE1BEF23821F960DECBEC5083641681AE6C048942C52D3975C3106BC6B1EE9C1B6DD939E5B7A43A1DF9C191FC4C7AE56C42A06CA735677A4FC6C4F18E982D1FA602C5C2EA0639AA1712FD2EECEA777EC5E780B4B98E0828DA459CEC1E1E4B6672BD27310EC7A7609D3B44865AB13EDC609F0331E841E298DE51FA20D6AD3470BFA032358E4FAB11BCC92081E0AA59C3B2B3CC10D847C9F1E00C45E476818EBDB4F5";
  //
  // final params = EapiCrypto.paramsDecrypt(data);
  // print(params.path);
  // print(params.json);
  // print(params.hash);

  final data = "72 3B 4D 78 A0 8E 2C 3F 83 04 11 49 28 F1 0A 3D 2C 0C 4C AF A5 0C E3 92 3F 8D 22 A7 D1 6A 9A 15 E8 50 F8 55 2B C4 B4 9E 9B 9A 29 AA 24 5C 32 BB A2 F3 D2 DB C0 54 D6 CD 99 A8 B5 49 2D 6C E2 F3 3B 76 CA DD 5C 9C 61 AE 75 99 AD 84 BA 24 83 62 78 7F ED 42 3B 31 C4 CC 07 33 75 55 1B B6 38 BA FF 5A B4 DD A6 BB 09 B1 CF 55 AF 81 0C 08 98 28 2A 9F CD 95 F4 AC 91 1F E2 F3 D2 C7 B0 CF 3F 52 83 3A 6B 9C DC DD 3B 0E 4A FE 1B B5 B1 17 EE DC 12 49 54 92 4F 3A 1E D6 0D 4F E1 37 4A C4 EA A5 48 22 B5 61 DF 35 AA 58 8C 67 D0 53 26 30 A8 25 93 70 E4 4A FE F1 1C C0 F9 3E 07 7E CD 4D DC 87 74 F4 8F 6A E4 99 7B E9 5A D7 47 F4 A0 12 8C 38";
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
