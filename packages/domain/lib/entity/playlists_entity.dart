import 'dart:convert';

import 'package:domain/entity/account_entity.dart';

class PlaylistsEntity {
  final bool more;
  final List<PlaylistItemEntity> playlists;

  const PlaylistsEntity(this.more, this.playlists);

  void sortById() {
    playlists.sort((a, b) {
      return a.id.compareTo(b.id);
    });
  }

  PlaylistItemEntity? findLovedPlaylist() {
    for (final playlist in playlists) {
      if (playlist.type == 5) {
        return playlist;
      }
    }
    return null;
  }

  static PlaylistsEntity parseJson(String string) {
    final json = jsonDecode(string);
    final playlistJson = json["playlist"] as List;
    List<PlaylistItemEntity> parsedPlaylists = [];
    for (final itemJson in playlistJson) {
      parsedPlaylists.add(PlaylistItemEntity.parseJson(jsonEncode(itemJson)));
    }

    return PlaylistsEntity(json["more"], parsedPlaylists);
  }
}

class PlaylistItemEntity {
  final int id;
  final String name;
  final String? description;
  /// specialType，
  /// 5 为喜欢的音乐
  final int type;
  final bool privacy;

  final bool? subscribed;
  final int subscribedCount;

  final int createTime;
  final int updateTime;

  final String coverImgUrl;

  final int playCount;
  final int commentCount;
  /// trackCount
  final int songCount;
  /// cloudTrackCount
  final int cloudSongCount;

  final Profile creator;

  const PlaylistItemEntity(
    this.id,
      this.name,
      this.description,
      this.type,
      this.privacy,
      this.subscribed,
      this.subscribedCount,
      this.createTime,
      this.updateTime,
      this.coverImgUrl,
      this.playCount,
      this.commentCount,
      this.songCount,
      this.cloudSongCount,
      this.creator
  );

  static PlaylistItemEntity parseJson(String string) {
    final json = jsonDecode(string);

    return PlaylistItemEntity(
      json["id"] ?? -1,
      json["name"] ?? "",
      json["description"] ?? "",
      json["specialType"] ?? -1,
      json["privacy"] == 0,
      json["subscribed"] ?? false,
      json["subscribedCount"] ?? -1,
      json["createTime"] ?? -1,
      json["updateTime"] ?? -1,
      json["coverImgUrl"] ?? "",
      json["playCount"] ?? -1,
      json["commentCount"] ?? -1,
      json["trackCount"] ?? -1,
      json["cloudTrackCount"] ?? -1,
      Profile.parseJson(jsonEncode(json["creator"] ?? {}))
    );
  }
}
