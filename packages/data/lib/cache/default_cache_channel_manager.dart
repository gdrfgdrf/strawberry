import 'dart:io';

import 'package:data/cache/cache_hit.dart';
import 'package:data/cache/cache_system.dart';
import 'package:data/isolatepool/task_chain.dart';
import 'package:hive_ce/hive.dart';
import 'package:mutex/mutex.dart';
import 'package:natives/wrap/fastfile_wrapper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/v4.dart';

class _InternalLockManager {
  final map = <String, ReadWriteMutex>{};

  Future<void> write(String tag) async {
    if (!map.containsKey(tag)) {
      map[tag] = ReadWriteMutex();
    }
    await map[tag]!.acquireWrite();
  }

  void release(String tag) {
    if (!map.containsKey(tag)) {
      return;
    }
    map[tag]!.release();
  }

  Future<void> read(String tag) async {
    if (!map.containsKey(tag)) {
      return;
    }
    await map[tag]!.acquireRead();
  }
}

class DefaultCacheChannelManagerFactory extends CacheChannelManagerFactory {
  @override
  CacheChannelManager create(CacheChannel channel, Box<CacheInfo> box) {
    return DefaultCacheChannelManager(box, channel);
  }
}

class DefaultCacheChannelManager extends CacheChannelManager {
  final CacheChannel channel;
  final _InternalLockManager _lockManager = _InternalLockManager();
  CacheHitBehaviour? cacheHitBehaviour;

  DefaultCacheChannelManager(super.box, this.channel) {
    cacheHitBehaviour = CacheHitBehaviour(channel);
  }

  @override
  void cache(String tag, String sentence, List<int> bytes, {String? extension}) async {
    final exist = box.get(tag);
    if (exist != null) {
      update(tag, sentence, bytes);
      return;
    }

    await _lockManager.write(tag);

    final filename = UuidV4().generate();
    String path = await buildPath(filename);
    if (extension != null) {
      path = "$path.$extension";
    }

    TaskChain()
        .writeFile(() => path, () => bytes)
        .onComplete((_, _) {
          final cacheInfo = CacheInfo(tag, filename, 0, extension);
          cacheHitBehaviour!.createHit(tag, sentence);
          box.put(tag, cacheInfo);
          _lockManager.release(tag);
        })
        .run();
  }

  @override
  bool shouldUpdate(String tag, String sentence) {
    return cacheHitBehaviour!.shouldUpdate(tag, sentence);
  }

  @override
  void update(String tag, String sentence, List<int> bytes) async {
    final cacheInfo = box.get(tag);
    if (cacheInfo == null) {
      cache(tag, sentence, bytes);
      return;
    }

    await _lockManager.write(tag);

    final filename = cacheInfo.buildFilename();
    final path = await buildPath(filename);

    TaskChain()
        .writeFile(() => path, () => bytes)
        .onComplete((_, _) {
          cacheHitBehaviour!.update(tag, sentence);
          _lockManager.release(tag);
        }).run();
  }

  @override
  Future<List<int>> fetch(String tag) async {
    final cacheInfo = box.get(tag);
    if (cacheInfo == null) {
      throw Exception("$tag is not cached");
    }

    final filename = cacheInfo.buildFilename();
    final path = await buildPath(filename);
    final file = File(path);
    if (!await file.exists()) {
      throw Exception("file $path is not exists");
    }

    await _lockManager.read(tag);

    final fastFile = DartFastFile(path);
    fastFile.open();
    final bytes = fastFile.copy();

    _lockManager.release(tag);

    return bytes;
  }

  @override
  Future<String> path(String tag) async {
    final cacheInfo = box.get(tag);
    if (cacheInfo == null) {
      throw Exception("$tag is not cached");
    }

    final filename = cacheInfo.buildFilename();
    final path = await buildPath(filename);
    return path;
  }

  Future<String> buildPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final dataPath =
        "${directory.path}${Platform.pathSeparator}strawberry_data/${channel.boxName}";
    final dataDirectory = Directory(dataPath);
    if (!await dataDirectory.exists()) {
      await dataDirectory.create(recursive: true);
    }

    final path = "$dataPath/$filename";
    return path;
  }
}
