import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:domain/hives.dart';

@HiveType(typeId: HiveTypes.artistId)
class ArtistEntity {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int? accountId;
  @HiveField(2)
  final String name;
  /// briefDesc
  @HiveField(3)
  final String description;

  /// picUrl
  @HiveField(4)
  final String backgroundUrl;

  /// img1v1Url
  @HiveField(5)
  final String avatarUrl;

  /// albumSize（谁教你这么起名的）
  @HiveField(6)
  final int albumCount;

  /// musicSize（谁教你这么起名的 x2）
  @HiveField(7)
  final int musicCount;

  /// mvSize（谁教你这么起名的 x3）
  @HiveField(8)
  final int musicVideo;

  @HiveField(9)
  final bool followed;

  /// 这个是真别名
  @HiveField(10)
  final List<String> alias;

  ArtistEntity(
    this.id,
    this.accountId,
    this.name,
    this.description,
    this.backgroundUrl,
    this.avatarUrl,
    this.albumCount,
    this.musicCount,
    this.musicVideo,
    this.followed,
    this.alias,
  );

  static ArtistEntity parseJson(String string) {
    final json = jsonDecode(string);

    List<String> alias = [];
    for (final alia in json["alias"] ?? []) {
      alias.add(alia);
    }

    return ArtistEntity(
      json["id"] ?? -1,
      json["accountId"],
      json["name"] ?? "",
      json["briefDesc"] ?? "",
      json["picUrl"] ?? "",
      json["img1v1Url"] ?? "",
      json["albumSize"] ?? -1,
      json["musicSize"] ?? -1,
      json["mvSize"] ?? -1,
      json["followed"] ?? false,
      alias,
    );
  }
}
