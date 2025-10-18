import 'dart:convert';

import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_privilege_entity.dart';

class IndependentOption<T> {
  const IndependentOption();
}

class IndependentSome<T> extends IndependentOption<T> {
  final T value;

  const IndependentSome(this.value);
}

class IndependentNone<T> extends IndependentOption<T> {}

class SongQueryEntity {
  /// 查询时，不论提供 id 是否有效，后者都会存在，即使提供的 id 有重复
  /// 比如提供两个 id 都为 -1 的作为参数，也会返回两个 privilege，但有不有效另说，
  /// 但若 id 无效，前者则不会存在
  final Map<IndependentOption<SongEntity>, SongPrivilegeEntity> map;

  const SongQueryEntity(this.map);

  static SongQueryEntity parseJson(String string) {
    final json = jsonDecode(string);

    final Map<int, SongEntity> tempSongs = {};
    Map<IndependentOption<SongEntity>, SongPrivilegeEntity> result = {};

    for (final songJson in json["songs"] ?? []) {
      final entity = SongEntity.parseJson(jsonEncode(songJson ?? {}));
      tempSongs[entity.id] = entity;
    }
    for (final privilegeJson in json["privileges"] ?? []) {
      final entity = SongPrivilegeEntity.parseJson(
        jsonEncode(privilegeJson ?? {}),
      );
      final id = entity.id;

      SongEntity? songEntity = tempSongs[id];
      IndependentOption<SongEntity> wrappedSongEntity;
      if (songEntity != null) {
        wrappedSongEntity = IndependentSome(songEntity);
      } else {
        wrappedSongEntity = IndependentNone();
      }

      result[wrappedSongEntity] = entity;
    }

    return SongQueryEntity(result);
  }
}
