import 'dart:convert';

import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:hive_ce/hive.dart';
import 'package:domain/hives.dart';

@HiveType(typeId: HiveTypes.songPrivilegeId)
class SongPrivilegeEntity {
  @HiveField(0)
  final int id;

  /// fee
  @HiveField(1)
  final SongPurchaseType purchase;

  /// payed
  /// 0：未购买 (?)
  /// 3: 已购买单曲
  @HiveField(2)
  final int purchased;

  /// st
  /// 小于 0 时该值为 false，大于等于 0 时该值为 true
  @HiveField(3)
  final bool available;

  /// cs
  /// 是否为云盘歌曲
  @HiveField(4)
  final bool cloudMusic;

  /// maxbr
  @HiveField(5)
  final int maxBitrate;

  /// maxBrLevel
  @HiveField(6)
  final SongQualityLevel maxBitrateLevel;

  /// playMaxbr
  @HiveField(7)
  final int playMaxBitrate;

  /// playMaxBrLevel
  @HiveField(8)
  final SongQualityLevel playMaxBitrateLevel;

  /// downloadMaxbr
  @HiveField(9)
  final int downloadMaxBitrate;

  /// downloadMaxbBrLevel
  @HiveField(10)
  final SongQualityLevel downloadMaxBitrateLevel;

  /// flLevel，免费用户的音质
  @HiveField(11)
  final SongQualityLevel freeQuality;

  /// dlLevel，当前用户的最高下载音质
  @HiveField(12)
  final SongQualityLevel downloadQuality;

  /// plLevel，当前用户的最高播放音质
  @HiveField(13)
  final SongQualityLevel playQuality;

  /// 是否显示 由于版权保护，您所在的地区暂时无法使用
  @HiveField(14)
  final bool toast;

  const SongPrivilegeEntity(
    this.id,
    this.purchase,
    this.purchased,
    this.available,
    this.cloudMusic,
    this.maxBitrate,
    this.maxBitrateLevel,
    this.playMaxBitrate,
    this.playMaxBitrateLevel,
    this.downloadMaxBitrate,
    this.downloadMaxBitrateLevel,
    this.freeQuality,
    this.downloadQuality,
    this.playQuality,
    this.toast,
  );

  static SongPrivilegeEntity parseJson(String string) {
    final json = jsonDecode(string);
    return SongPrivilegeEntity(
      json["id"] ?? -1,
      SongPurchaseType.parseNum(json["fee"] ?? 0),
      json["payed"] ?? -1,
      json["st"] >= 0,
      json["cs"] ?? false,
      json["maxbr"] ?? -1,
      SongQualityLevel.parseString(json["maxBrLevel"] ?? "standard"),
      json["playMaxbr"] ?? -1,
      SongQualityLevel.parseString(json["playMaxBrLevel"] ?? "standard"),
      json["downloadMaxbr"] ?? -1,
      SongQualityLevel.parseString(json["downloadMaxBrLevel"] ?? "standard"),
      SongQualityLevel.parseString(json["flLevel"] ?? "standard"),
      SongQualityLevel.parseString(json["dlLevel"] ?? "standard"),
      SongQualityLevel.parseString(json["plLevel"] ?? "standard"),
      json["toast"] ?? false,
    );
  }
}
