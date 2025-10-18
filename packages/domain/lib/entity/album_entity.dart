import 'dart:convert';

import 'package:domain/entity/artist_entity.dart';
import 'package:domain/entity/mark_entity.dart';
import 'package:domain/entity/song_entity.dart';
import 'package:hive_ce/hive.dart';
import 'package:domain/hives.dart';

@HiveType(typeId: HiveTypes.basicAlbumId)
class BasicAlbumEntity {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String picUrl;
  @HiveField(3)
  final List<String> localizedNames;

  const BasicAlbumEntity(this.id, this.name, this.picUrl, this.localizedNames);

  static BasicAlbumEntity parseJson(String string) {
    final json = jsonDecode(string);

    List<String> localizedNames = [];
    for (final name in json["tns"] ?? []) {
      localizedNames.add(name);
    }

    return BasicAlbumEntity(
      json["id"] ?? -1,
      json["name"] ?? "",
      json["picUrl"] ?? "",
      localizedNames,
    );
  }
}

class AlbumEntity {
  final AlbumInfo info;
  final List<SongEntity> songs;
  final InnerAlbumEntity innerAlbum;

  const AlbumEntity(this.info, this.songs, this.innerAlbum);

  static AlbumEntity parseJson(String string) {
    final json = jsonDecode(string);

    final infoString = jsonEncode(json["info"] ?? {});
    final info = AlbumInfo.parseJson(infoString);

    List<SongEntity> songs = [];
    for (final song in json["songs"] ?? []) {
      songs.add(SongEntity.parseJson(jsonEncode(song ?? {})));
    }

    final innerAlbumString = jsonEncode(json["album"] ?? {});
    final innerAlbum = InnerAlbumEntity.parseJson(innerAlbumString);

    return AlbumEntity(info, songs, innerAlbum);
  }
}

class AlbumInfo {
  /// 3: 专辑
  final int resourceType;
  final int commentCount;
  final int likedCount;
  final int shareCount;

  const AlbumInfo(
    this.resourceType,
    this.commentCount,
    this.likedCount,
    this.shareCount,
  );

  static AlbumInfo parseJson(String string) {
    final json = jsonDecode(string);
    return AlbumInfo(
      json["resourceType"] ?? -1,
      json["commentCount"] ?? -1,
      json["likedCount"] ?? -1,
      json["shareCount"] ?? -1,
    );
  }
}

class InnerAlbumEntity {
  final int id;
  final String name;
  final String description;
  final String company;

  final ArtistEntity mainArtist;
  final List<ArtistEntity> artists;

  /// 专辑，EP，Single，精选集，合集，DEMO
  final String type;

  /// 录音室版
  final String subType;
  final int size;

  /// 主译名
  final String? transName;

  /// 译名
  final List<String>? transNames;

  /// alias
  /// 出处
  final List<String> sources;
  final bool onSale;
  /// mark
  final List<MarkType> marks;

  final String picUrl;

  final int publishTime;

  const InnerAlbumEntity(
    this.id,
    this.name,
    this.description,
    this.company,
    this.mainArtist,
    this.artists,
    this.type,
    this.subType,
    this.size,
    this.transName,
    this.transNames,
    this.sources,
    this.onSale,
    this.marks,
    this.picUrl,
    this.publishTime,
  );

  static InnerAlbumEntity parseJson(String string) {
    final json = jsonDecode(string);

    List<String> sources = [];
    for (final source in json["alias"] ?? []) {
      sources.add(source);
    }

    List<ArtistEntity> artists = [];
    for (final artistJson in json["artists"] ?? []) {
      artists.add(ArtistEntity.parseJson(jsonEncode(artistJson ?? {})));
    }

    return InnerAlbumEntity(
      json["id"] ?? -1,
      json["name"] ?? "",
      json["description"] ?? "",
      json["company"] ?? "",
      ArtistEntity.parseJson(jsonEncode(json["artist"] ?? {})),
      artists,
      json["type"] ?? "",
      json["subType"] ?? "",
      json["size"] ?? -1,
      json["transName"],
      json["transNames"],
      sources,
      json["onSale"] ?? false,
      MarkType.calculate(json["mark"] ?? -1),
      json["picUrl"] ?? "",
      json["publishTime"] ?? -1,
    );
  }
}
