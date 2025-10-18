import 'dart:io';

import 'package:data/cache/default_cache_channel_manager.dart';
import 'package:domain/hives.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

enum CacheChannel {
  avatars("avatars"),
  playlistCovers("playlist-covers"),
  albumCovers("album-covers"),

  ;

  final String boxName;

  const CacheChannel(this.boxName);

  Box<CacheInfo> getBox() {
    return Hive.box(boxName);
  }
}

abstract class CacheChannelManagerFactory {
  CacheChannelManager create(CacheChannel channel, Box<CacheInfo> box);
}

abstract class CacheChannelManager {
  final Box<CacheInfo> box;

  CacheChannelManager(this.box);

  void cache(String tag, String sentence, List<int> bytes, {String? extension});

  void update(String tag, String sentence, List<int> bytes);

  bool shouldUpdate(String tag, String sentence);

  Future<List<int>> fetch(String tag);

  Future<String> path(String tag);
}

@HiveType(typeId: HiveTypes.cacheInfoId)
class CacheInfo {
  @HiveField(0)
  final String tag;
  @HiveField(1)
  final String filename;
  @HiveField(2)
  final int accessCount;
  @HiveField(3)
  final String? extension;

  CacheInfo(this.tag, this.filename, this.accessCount, this.extension);

  String buildFilename() {
    if (extension != null) {
      return "$filename.$extension";
    }
    return filename;
  }
}

class CacheSystem {
  final map = <CacheChannel, CacheChannelManager>{};

  Future<void> initialize() async {
    configureGetIt();

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}${Platform.pathSeparator}strawberry_data";

    final managerFactory = GetIt.instance.get<CacheChannelManagerFactory>();
    for (final channel in CacheChannel.values) {
      final boxName = channel.boxName;
      final box = await Hive.openBox<CacheInfo>(boxName, path: path);
      final manager = managerFactory.create(channel, box);
      map[channel] = manager;
    }
  }

  void configureGetIt() {
    GetIt.instance.registerLazySingleton<CacheChannelManagerFactory>(
      () => DefaultCacheChannelManagerFactory(),
    );
  }

  CacheChannelManager manager(CacheChannel channel) {
    return map[channel]!;
  }
}
