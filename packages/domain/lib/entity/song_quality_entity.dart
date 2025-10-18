import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:domain/hives.dart';

@HiveType(typeId: HiveTypes.songQualityLevelId)
enum SongQualityLevel {
  @HiveField(0)
  standard(0),
  @HiveField(1)
  higher(1),
  @HiveField(2)
  exhigh(2),
  /// 无损
  @HiveField(3)
  lossless(3),
  @HiveField(4)
  hires(4),
  /// 高清环绕声
  @HiveField(5)
  jyeffect(5),
  /// 沉浸环绕声
  @HiveField(6)
  sky(6),
  @HiveField(7)
  dolby(7),
  /// 超清母带
  @HiveField(8)
  jymaster(8),
  @HiveField(9)
  none(9)

  ;

  final int num;

  const SongQualityLevel(this.num);

  static SongQualityLevel parseNum(int num) {
    switch (num) {
      case 0: return SongQualityLevel.standard;
      case 1: return SongQualityLevel.higher;
      case 2: return SongQualityLevel.exhigh;
      case 3: return SongQualityLevel.lossless;
      case 4: return SongQualityLevel.hires;
      case 5: return SongQualityLevel.jyeffect;
      case 6: return SongQualityLevel.sky;
      case 7: return SongQualityLevel.dolby;
      case 8: return SongQualityLevel.jymaster;
      case 9: return SongQualityLevel.none;
      default: return SongQualityLevel.standard;
    }
  }

  static SongQualityLevel parseString(String string) {
    switch (string) {
      case "standard": return SongQualityLevel.standard;
      case "higher": return SongQualityLevel.higher;
      case "exhigh": return SongQualityLevel.exhigh;
      case "lossless": return SongQualityLevel.lossless;
      case "hires": return SongQualityLevel.hires;
      case "jyeffect": return SongQualityLevel.jyeffect;
      case "sky": return SongQualityLevel.sky;
      case "dolby": return SongQualityLevel.dolby;
      case "jymaster": return SongQualityLevel.jymaster;
      default: return SongQualityLevel.standard;
    }
  }
}

@HiveType(typeId: HiveTypes.songQualityId)
class SongQualityEntity {
  /// 码率 Bitrate
  @HiveField(0)
  final int br;

  /// 未知，疑似始终为 0
  @HiveField(1)
  final int fid;

  /// 大小
  @HiveField(2)
  final int size;

  /// vd
  @HiveField(3)
  final double volumeDelta;

  /// 采样率 Sample rate
  @HiveField(4)
  final double sr;

  const SongQualityEntity(this.br, this.fid, this.size, this.volumeDelta, this.sr);

  static SongQualityEntity parseJson(String string) {
    final json = jsonDecode(string);
    return SongQualityEntity(
      json["br"] ?? -1,
      json["fid"] ?? -1,
      json["size"] ?? -1,
      json["vd"] ?? -1,
      double.parse((json["sr"] ?? 1.0).toString()),
    );
  }
}
