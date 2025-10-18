import 'dart:convert';

import 'package:domain/entity/album_entity.dart';
import 'package:domain/entity/artist_entity.dart';
import 'package:domain/entity/mark_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:domain/hives.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared/string_extension.dart';

/// 演唱类型，
@HiveType(typeId: HiveTypes.songSingId)
enum SongSingType {
  @HiveField(0)
  unknown(0),

  /// 原唱
  @HiveField(1)
  original(1),

  /// 翻唱
  @HiveField(2)
  cover(2);

  final int num;

  const SongSingType(this.num);

  static SongSingType parseNum(int num) {
    switch (num) {
      case 0:
        return SongSingType.unknown;
      case 1:
        return SongSingType.original;
      case 2:
        return SongSingType.cover;
      default:
        return SongSingType.unknown;
    }
  }
}

@HiveType(typeId: HiveTypes.songPurchaseId)
enum SongPurchaseType {
  @HiveField(0)
  freeOrNoCopyright(0),
  @HiveField(1)
  onlyVip(1),
  @HiveField(2)
  albumPurchase(4),

  /// 非会员可免费播放低音质，会员可播放高音质及下载
  @HiveField(3)
  vipHigh(8);

  final int num;

  const SongPurchaseType(this.num);

  static SongPurchaseType parseNum(int num) {
    switch (num) {
      case 0:
        return SongPurchaseType.freeOrNoCopyright;
      case 1:
        return SongPurchaseType.onlyVip;
      case 4:
        return SongPurchaseType.albumPurchase;
      case 8:
        return SongPurchaseType.vipHigh;
      default:
        return SongPurchaseType.freeOrNoCopyright;
    }
  }
}

/// Json 中的 t 参数
@HiveType(typeId: HiveTypes.songMatchId)
enum SongMatchType {
  @HiveField(0)
  normal(0),

  /// 不存在公开对应
  @HiveField(1)
  cloudIndependent(1),

  /// 存在公开对应
  @HiveField(2)
  cloudNonIndependent(2);

  final int num;

  const SongMatchType(this.num);

  static SongMatchType parseNum(int num) {
    switch (num) {
      case 0:
        return SongMatchType.normal;
      case 1:
        return SongMatchType.cloudIndependent;
      case 2:
        return SongMatchType.cloudNonIndependent;
      default:
        return SongMatchType.normal;
    }
  }
}

@HiveType(typeId: HiveTypes.cloudMusicInfoId)
class CloudMusicInfo {
  /// uid
  @HiveField(0)
  final int userId;

  /// cid
  @HiveField(1)
  final String coverId;

  /// nickname
  @HiveField(2)
  final String name;

  /// fn
  @HiveField(3)
  final String filename;

  /// sn
  @HiveField(4)
  final String songName;

  /// ar
  @HiveField(5)
  final String artist;

  /// br, bitrate
  @HiveField(6)
  final int bitrate;

  const CloudMusicInfo(
    this.userId,
    this.coverId,
    this.name,
    this.filename,
    this.songName,
    this.artist,
    this.bitrate,
  );

  static CloudMusicInfo parseJson(String string) {
    final json = jsonDecode(string);

    return CloudMusicInfo(
      json["uid"] ?? -1,
      json["cid"] ?? "",
      json["nickname"] ?? "",
      json["fn"] ?? "",
      json["sn"] ?? "",
      json["ar"] ?? "",
      json["br"] ?? -1,
    );
  }
}

/// 原唱歌曲的基础信息
@HiveType(typeId: HiveTypes.songOriginalBasicDataId)
class SongOriginBasicData {
  /// songId
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;

  /// 仅提供 id，name 字段
  @HiveField(2)
  final List<ArtistEntity> artists;

  /// albumMeta，仅提供 id，name 字段
  @HiveField(3)
  final BasicAlbumEntity basicAlbum;

  const SongOriginBasicData(this.id, this.name, this.artists, this.basicAlbum);

  static SongOriginBasicData parseJson(String string) {
    final json = jsonDecode(string);

    List<ArtistEntity> artists = [];
    for (final artistJson in json["artists"] ?? []) {
      artists.add(ArtistEntity.parseJson(jsonEncode(artistJson ?? {})));
    }

    return SongOriginBasicData(
      json["id"] ?? -1,
      json["name"] ?? "",
      artists,
      BasicAlbumEntity.parseJson(jsonEncode(json["albumMeta"] ?? {})),
    );
  }
}

@HiveType(typeId: HiveTypes.songId)
class SongEntity {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? mainTitle;
  @HiveField(3)
  final String? additionalTitle;

  /// dt
  @HiveField(4)
  final Duration duration;

  /// al
  @HiveField(5)
  final BasicAlbumEntity? basicAlbum;

  /// single
  /// 为 1 表示未知专辑且该值为 false，为 0 表示有专辑信息或为 DJ 节目且该值为 true
  @HiveField(6)
  final bool owned;

  /// alia
  /// 歌曲出处
  /// 乱的要死，有些歌拿这个当出处，有些歌拿这个当别名，但拿这个当出处的多
  @HiveField(7)
  final List<String> sources;

  /// tns
  /// 歌曲名的本地译名
  /// 依旧乱的要死，有些歌的这玩意不是中文，但大部分是中文
  /// 还有些歌的这玩意有中文，但中文在上面那个 sources 里面，这里只有英文
  @HiveField(8)
  final List<String> localizedNames;

  /// ar 返回体中有效值仅有 id，name 字段，其余字段均无效
  @HiveField(9)
  final List<ArtistEntity> artists;

  /// originCoverType
  @HiveField(10)
  final SongSingType singType;

  // /// originSongSimpleData
  // /// 当 singType == cover 时，该值可能存在
  // @HiveField(11)
  // final SongOriginBasicData? originBasicData;

  /// fee
  @HiveField(12)
  final SongPurchaseType purchase;

  /// 注释掉这些，不然在一个超长的歌单的时候，SongQualityEntity 的实例数会特别多
  // /// h 高质量
  // @HiveField(13)
  // final SongQualityEntity? highQuality;
  //
  // /// m 中等质量
  // @HiveField(14)
  // final SongQualityEntity? mediumQuality;
  //
  // /// l 低质量
  // @HiveField(15)
  // final SongQualityEntity? lowQuality;
  //
  // /// sq 超高质量
  // @HiveField(16)
  // final SongQualityEntity? superQuality;
  //
  // /// hr Hi-Res 质量
  // @HiveField(17)
  // final SongQualityEntity? hiResQuality;

  /// noCopyrightRcmd
  /// 当 noCopyrightRcmd 字段存在时，该值为 false，反之
  @HiveField(18)
  final bool hasCopyright;

  /// cd
  /// 歌曲所属 CD 在专辑中的序号。
  /// 可能为数字，长度为 2 时，缺十位则补零，长度也可能为 1
  /// 可能为分数，如 1/1, 1/2。
  @HiveField(19)
  final String? cdOrder;

  /// no
  /// 歌曲在所属 CD 中的序号，为 0 表示歌曲不存在于 CD 中
  @HiveField(20)
  final int order;

  /// djId，0 表示不是 DJ 节目，其他值则为 DJ 节目 ID
  @HiveField(21)
  final int djId;

  /// mv，0 表示无 MV，其他值则为 MV ID
  @HiveField(22)
  final int mvId;

  /// t
  @HiveField(23)
  final SongMatchType match;

  /// mark
  @HiveField(24)
  final List<MarkType> marks;

  /// s_id
  /// 当 source == cloudNonIndependent 时，该值表示匹配到的歌曲的 id。
  /// 当 source 为其他值时，该值为 0
  @HiveField(25)
  final int relation;

  /// pc
  /// 云盘音乐信息，该歌曲存在与用户云盘中
  /// 当 source == cloudIndependent 时，该值可能存在
  @HiveField(26)
  final CloudMusicInfo? cloudMusicInfo;

  /// pop [0.0, 100.0]
  @HiveField(27)
  final double popular;

  @HiveField(28)
  final int publishTime;

  const SongEntity(
    this.id,
    this.name,
    this.mainTitle,
    this.additionalTitle,
    this.duration,
    this.basicAlbum,
    this.owned,
    this.sources,
    this.localizedNames,
    this.artists,
    this.singType,
    // this.originBasicData,
    this.purchase,
    // this.highQuality,
    // this.mediumQuality,
    // this.lowQuality,
    // this.superQuality,
    // this.hiResQuality,
    this.hasCopyright,
    this.cdOrder,
    this.order,
    this.djId,
    this.mvId,
    this.match,
    this.marks,
    this.relation,
    this.cloudMusicInfo,
    this.popular,
    this.publishTime,
  );

  String compatibleAlbumId() {
    String albumId = basicAlbum?.id.toString() ?? "-1";
    if (albumId == "-1" || albumId == "0") {
      albumId = "song-$id";
    }
    return albumId;
  }

  SongQualityEntity? findQuality(int bitrate) {
    final qualities = availableQualities();
    if (qualities.isEmpty) {
      return null;
    }

    SongQualityEntity? matchedQuality;
    for (final quality in qualities) {
      if (quality.br <= bitrate) {
        matchedQuality = quality;
      }
    }
    return matchedQuality;
  }

  List<SongQualityEntity> availableQualities() {
    List<SongQualityEntity> result = [];

    // if (highQuality != null) {
    //   result.add(highQuality!);
    // }
    // if (mediumQuality != null) {
    //   result.add(mediumQuality!);
    // }
    // if (lowQuality != null) {
    //   result.add(lowQuality!);
    // }
    // if (superQuality != null) {
    //   result.add(superQuality!);
    // }
    // if (hiResQuality != null) {
    //   result.add(hiResQuality!);
    // }

    return result;
  }

  String formatDuration() {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  String buildArtists() {
    String end = " / ";
    String result = "";

    for (int i = 0; i < artists.length; i++) {
      if (i >= artists.length - 1) {
        end = "";
      }

      final name = artists[i].name;
      result = result + name + end;
    }

    return result;
  }

  bool search(String search) {
    if (search.isBlank()) {
      return true;
    }

    final searchLower = search.toLowerCase().trim();

    return _matchesId(id, searchLower) ||
        _matchesString(name, searchLower) ||
        _matchesString(basicAlbum?.name ?? "", searchLower) ||
        _matchesList(
          artists.map((artist) => artist.name).toList(),
          searchLower,
        ) ||
        _matchesList(localizedNames, searchLower) ||
        _matchesList(sources, searchLower);
  }

  static bool _matchesId(int id, String search) {
    return id.toString().contains(search);
  }

  static bool _matchesString(String field, String search) {
    if (field.isEmpty) {
      return false;
    }
    return field.toLowerCase().contains(search);
  }

  static bool _matchesList(List<String> list, String search) {
    if (list.isEmpty) {
      return false;
    }

    for (final item in list) {
      if (item.toLowerCase().contains(search)) {
        return true;
      }
    }
    return false;
  }

  static SongEntity parseJson(String string) {
    final json = jsonDecode(string);

    List<String> sources = [];
    for (final source in json["alia"] ?? []) {
      sources.add(source);
    }

    List<String> localizedNames = [];
    for (final name in json["tns"] ?? []) {
      localizedNames.add(name);
    }

    List<ArtistEntity> artists = [];
    for (final artistJson in json["ar"] ?? []) {
      artists.add(ArtistEntity.parseJson(jsonEncode(artistJson ?? {})));
    }

    return SongEntity(
      json["id"] ?? -1,
      json["name"] ?? "",
      json["mainTitle"],
      json["additionalTitle"],
      Duration(milliseconds: json["dt"] ?? 0),
      json["al"] != null
          ? BasicAlbumEntity.parseJson(jsonEncode(json["al"] ?? {}))
          : null,
      json["single"] == 0,
      sources,
      localizedNames,
      artists,
      SongSingType.parseNum(json["originCoverType"] ?? 0),
      // SongOriginBasicData.parseJson(
      //   jsonEncode(json["originSongSimpleData"] ?? {}),
      // ),
      SongPurchaseType.parseNum(json["fee"]),
      // SongQualityEntity.parseJson(jsonEncode(json["h"] ?? {})),
      // SongQualityEntity.parseJson(jsonEncode(json["m"] ?? {})),
      // SongQualityEntity.parseJson(jsonEncode(json["l"] ?? {})),
      // SongQualityEntity.parseJson(jsonEncode(json["sq"] ?? {})),
      // SongQualityEntity.parseJson(jsonEncode(json["hr"] ?? {})),
      json["noCopyrightRcmd"] == null,
      json["cd"],
      json["no"] ?? -1,
      json["djId"] ?? -1,
      json["mv"] ?? -1,
      SongMatchType.parseNum(json["t"] ?? 0),
      MarkType.calculate(json["mark"] ?? -1),
      json["s_id"] ?? -1,
      json["pc"] != null
          ? CloudMusicInfo.parseJson(jsonEncode(json["pc"] ?? {}))
          : null,
      json["pop"] ?? -1,
      json["publishTime"] ?? -1,
    );
  }
}
