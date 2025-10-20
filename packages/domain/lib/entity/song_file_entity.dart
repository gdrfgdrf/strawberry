import 'dart:convert';

import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:hive_ce/hive.dart';

import '../hives.dart';

@HiveType(typeId: HiveTypes.songFlagId)
enum SongFlag {
  @HiveField(0)
  noCopyright(0),

  /// 4 - 有版权无权限
  @HiveField(1)
  copyrighted(1 << 2),

  /// 64 - 试听
  @HiveField(2)
  freeTrial(1 << 6),

  /// 128 - 独家
  @HiveField(3)
  exclusive(1 << 7),

  /// 256 -

  /// 1024 - VIP 歌曲
  @HiveField(4)
  vipSong(1 << 10),

  /// 2048 - 专辑付费
  @HiveField(5)
  albumPurchase(1 << 11),

  /// 4096 - 官方版
  @HiveField(6)
  official(1 << 12),

  /// 8192 - 非官方版
  @HiveField(7)
  nonOfficial(1 << 13),

  /// 16384
  @HiveField(8)
  highQuality(1 << 14);

  final int num;

  const SongFlag(this.num);

  static List<SongFlag> calculate(int num) {
    List<SongFlag> result = [];

    for (final flag in SongFlag.values) {
      if (num & flag.num != 0) {
        result.add(flag);
      }
    }
    return result;
  }
}

@HiveType(typeId: HiveTypes.freeTrialInfoId)
class FreeTrialInfo {
  /// 起始位置，返回体中的值的单位为秒
  @HiveField(0)
  final int start;
  /// 结束位置，返回体中的值的单位为秒
  @HiveField(1)
  final int end;

  const FreeTrialInfo(this.start, this.end);

  static FreeTrialInfo parseJson(String string) {
    final json = jsonDecode(string);
    return FreeTrialInfo(json["start"] ?? -1, json["end"] ?? -1);
  }
}

@HiveType(typeId: HiveTypes.songFileId)
class SongFileEntity {
  @HiveField(0)
  final int id;
  /// 当前用户听不了时为 null
  @HiveField(1)
  final String? url;
  /// 请求时提供的 encodeType，注意不是下面那个 encodeType
  @HiveField(2)
  final String type;
  /// 文件实际编码类型
  @HiveField(3)
  final String encodeType;
  @HiveField(4)
  final int size;
  /// 该 level 为当前用户能获取到的最高 level，在 num 上始终小于等于请求时提供的 level
  @HiveField(5)
  final SongQualityLevel level;
  @HiveField(6)
  final List<SongFlag> flags;
  @HiveField(7)
  final int rawFlag;

  /// br
  @HiveField(8)
  final int bitrate;

  /// gain，有负值
  @HiveField(9)
  final double volumeDelta;

  /// 采样峰值，有负值。在网易云代码中没搜到相关，疑似无用
  @HiveField(10)
  final double peak;

  /// closedGain，设备支持动态范围压缩时的 volumeDelta，有负值
  @HiveField(11)
  final double closedVolumeDelta;

  /// 设备支持动态范围压缩时的 peak，有负值
  @HiveField(12)
  final double closedPeak;

  @HiveField(13)
  final String md5;

  /// expi，url的有效期，返回体中的值的单位为秒
  @HiveField(14)
  final Duration expireAfter;

  @HiveField(15)
  final FreeTrialInfo? freeTrialInfo;

  /// fee
  @HiveField(16)
  final SongPurchaseType purchase;

  /// payed
  @HiveField(17)
  final int purchased;

  /// time，返回体中的值的单位为毫秒
  @HiveField(18)
  final Duration duration;

  const SongFileEntity(
    this.id,
    this.url,
    this.type,
    this.encodeType,
    this.size,
    this.level,
    this.flags,
    this.rawFlag,
    this.bitrate,
    this.volumeDelta,
    this.peak,
    this.closedVolumeDelta,
    this.closedPeak,
    this.md5,
    this.expireAfter,
    this.freeTrialInfo,
    this.purchase,
    this.purchased,
    this.duration,
  );

  static SongFileEntity parseJson(String string) {
    final json = jsonDecode(string);

    return SongFileEntity(
      json["id"] ?? -1,
      json["url"],
      json["type"] ?? "",
      json["encodeType"] ?? "",
      json["size"] ?? -1,
      SongQualityLevel.parseString(json["level"] ?? "standard"),
      SongFlag.calculate(json["flag"] ?? 4),
      json["flag"] ?? 4,
      json["br"] ?? -1,
      double.parse((json["gain"] ?? 0).toString()),
      double.parse((json["peak"] ?? 0).toString()),
      double.parse((json["closedGain"] ?? 0).toString()),
      double.parse((json["closedPeak"] ?? 0).toString()),
      json["md5"] ?? "",
      Duration(seconds: json["expi"] ?? 0),
      json["freeTrialInfo"] != null
          ? FreeTrialInfo.parseJson(jsonEncode(json["freeTrialInfo"] ?? {}))
          : null,
      SongPurchaseType.parseNum(json["fee"] ?? 0),
      json["payed"] ?? -1,
      Duration(milliseconds: json["time"] ?? 0),
    );
  }
}
