import 'dart:convert';

import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/playlists_entity.dart';

class PlaylistQueryEntity {
  final PlaylistItemEntity playlist;

  /// tracks
  final List<SongEntity> songs;
  /// trackIds
  final List<PlaylistSongId> songIds;

  const PlaylistQueryEntity(
    this.playlist,
    this.songs,
    this.songIds,
  );

  bool lovedPlaylist() {
    return playlist.type == 5;
  }

  static PlaylistQueryEntity parseJson(String string) {
    final json = jsonDecode(string);


    List<PlaylistSongId> songIds = [];
    for (final songIdJson in json["playlist"]["trackIds"] ?? []) {
      songIds.add(PlaylistSongId.parseJson(jsonEncode(songIdJson ?? {})));
    }

    List<SongEntity> songs = [];
    for (final songJson in json["playlist"]["tracks"] ?? []) {
      songs.add(SongEntity.parseJson(jsonEncode(songJson ?? {})));
    }
    
    return PlaylistQueryEntity(
      PlaylistItemEntity.parseJson(jsonEncode(json["playlist"] ?? {})),
      songs,
      songIds
    );
  }
}

class PlaylistSongId {
  final int id;
  final int addTime;

  const PlaylistSongId(this.id, this.addTime);

  static PlaylistSongId parseJson(String string) {
    final json = jsonDecode(string);

    return PlaylistSongId(json["id"] ?? -1, json["at"] ?? -1);
  }
}
