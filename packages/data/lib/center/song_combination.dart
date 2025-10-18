
import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_privilege_entity.dart';
import 'package:hive_ce/hive.dart';
import 'package:domain/hives.dart';

@HiveType(typeId: HiveTypes.songCombinationId)
class SongCombination {
  @HiveField(0)
  final SongEntity song;
  @HiveField(1)
  final SongPrivilegeEntity privilege;

  SongCombination(this.song, this.privilege);
}