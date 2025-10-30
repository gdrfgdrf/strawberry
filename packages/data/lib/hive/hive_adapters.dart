import 'package:data/cache/cache_system.dart';
import 'package:data/center/song_combination.dart';
import 'package:domain/entity/account_entity.dart';
import 'package:domain/entity/album_entity.dart';
import 'package:domain/entity/artist_entity.dart';
import 'package:domain/entity/login_result.dart';
import 'package:domain/entity/mark_entity.dart';
import 'package:domain/entity/region_parser.dart';
import 'package:domain/entity/song_entity.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/song_privilege_entity.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:domain/entity/store_lyrics_entity.dart';
import 'package:domain/entity/user_habit_entity.dart';
import 'package:hive_ce/hive.dart';

import '../cache/cache_hit.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<CacheHit>(),
  AdapterSpec<SongCombination>(),
  AdapterSpec<SongEntity>(),
  AdapterSpec<BasicAlbumEntity>(),
  AdapterSpec<ArtistEntity>(),
  AdapterSpec<SongSingType>(),
  AdapterSpec<SongOriginBasicData>(),
  AdapterSpec<SongPurchaseType>(),
  AdapterSpec<SongQualityEntity>(),
  AdapterSpec<SongMatchType>(),
  AdapterSpec<MarkType>(),
  AdapterSpec<CloudMusicInfo>(),
  AdapterSpec<SongPrivilegeEntity>(),
  AdapterSpec<SongQualityLevel>(),
  AdapterSpec<LoginResult>(),
  AdapterSpec<Account>(),
  AdapterSpec<Profile>(),
  AdapterSpec<Gender>(),
  AdapterSpec<Province>(),
  AdapterSpec<City>(),
  AdapterSpec<CacheInfo>(),
  AdapterSpec<UserHabit>(),
  AdapterSpec<SongFileEntity>(),
  AdapterSpec<SongFlag>(),
  AdapterSpec<FreeTrialInfo>(),
  AdapterSpec<StoreLyric>(),
  AdapterSpec<StoreWordInfo>(),
  AdapterSpec<StoreWordBasedLyric>(),
  AdapterSpec<StoreStandardLyrics>(),
  AdapterSpec<StoreTranslatedLyrics>(),
  AdapterSpec<StoreRomanLyrics>(),
  AdapterSpec<StoreWordBasedLyrics>(),
  AdapterSpec<StoreLyrics>()
])
class HiveAdapters {}
