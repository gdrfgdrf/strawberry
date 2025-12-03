import 'dart:async';
import 'dart:io';

import 'package:data/cache/cache_system.dart';
import 'package:domain/hives.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

@HiveType(typeId: HiveTypes.cacheHitId)
class CacheHit {
  @HiveField(0)
  final String sentence;
  @HiveField(1)
  final int timestamp;

  CacheHit(this.sentence, this.timestamp);
}

class CacheHitBehaviour {
  final CacheChannel channel;
  Box<CacheHit>? cacheHits;
  Future<void>? initializationFuture;

  CacheHitBehaviour(this.channel) {
    final completer = Completer();
    initializationFuture = completer.future;

    getApplicationDocumentsDirectory().then((directory) {
      final path = "${directory.path}${Platform.pathSeparator}strawberry_data";
      Hive.openBox<CacheHit>("${channel.boxName}-cache-hit", path: path).then((box) {
        completer.complete();
        cacheHits = box;
      });
    });
  }

  void createHit(String tag, String sentence) async {
    await initializationFuture!;
    final cacheHit = CacheHit(sentence, DateTime.now().millisecondsSinceEpoch);
    cacheHits!.put(tag, cacheHit);
  }

  void update(String tag, String sentence) async {
    await initializationFuture!;
    createHit(tag, sentence);
  }

  void removeHit(String tag) async {
    await initializationFuture!;
    cacheHits!.delete(tag);
  }

  Future<bool> shouldUpdate(String tag, String sentence) async {
    await initializationFuture!;

    final cacheHit = cacheHits!.get(tag);
    if (cacheHit == null) {
      return true;
    }
    if (sentence == cacheHit.sentence) {
      return false;
    }
    return true;
  }
}
