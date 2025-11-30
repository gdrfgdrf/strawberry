import 'package:hive_ce/hive.dart';
import 'package:shared/lyric/lyric_parser.dart';

import '../hives.dart';

@HiveType(typeId: HiveTypes.storeLyricId)
class StoreLyric {
  @HiveField(0)
  final Duration position;
  @HiveField(1)
  final String? text;

  const StoreLyric(this.position, this.text);

  LyricUnit toRuntime() {
    return StandardLyric(position, text);
  }

  static StoreLyric fromRuntime(StandardLyric lyric) {
    return StoreLyric(lyric.position, lyric.text);
  }
}

@HiveType(typeId: HiveTypes.storeWordInfoId)
class StoreWordInfo {
  @HiveField(0)
  final String word;
  @HiveField(1)
  final Duration position;
  @HiveField(2)
  final Duration duration;

  const StoreWordInfo(this.word, this.position, this.duration);

  WordInfo toRuntime() {
    return WordInfo(word, position, duration);
  }

  static StoreWordInfo fromRuntime(WordInfo wordInfo) {
    return StoreWordInfo(wordInfo.word, wordInfo.position, wordInfo.duration);
  }
}

@HiveType(typeId: HiveTypes.storeWordBasedLyricId)
class StoreWordBasedLyric {
  @HiveField(0)
  final Duration position;
  @HiveField(1)
  final Duration duration;
  @HiveField(2)
  final String? text;
  @HiveField(3)
  final List<StoreWordInfo>? wordInfos;

  const StoreWordBasedLyric(
    this.position,
    this.duration,
    this.text,
    this.wordInfos,
  );

  LyricUnit toRuntime() {
    return WordBasedLyric(
      position,
      text,
      wordInfos?.map((store) => store.toRuntime()).toList(),
      duration,
    );
  }

  static StoreWordBasedLyric fromRuntime(WordBasedLyric lyric) {
    return StoreWordBasedLyric(
      lyric.position,
      lyric.duration,
      lyric.text,
      lyric.wordInfos?.map(StoreWordInfo.fromRuntime).toList(),
    );
  }
}

@HiveType(typeId: HiveTypes.storeStandardLyricsId)
class StoreStandardLyrics {
  @HiveField(0)
  final List<StoreLyric> lyrics;
  @HiveField(1)
  final List<int>? ignoration;

  const StoreStandardLyrics(this.lyrics, this.ignoration);

  List<LyricUnit> toRuntimeLyrics() {
    return lyrics.map((store) => store.toRuntime()).toList();
  }

  static StoreStandardLyrics fromRuntime(
    List<StandardLyric> lyrics,
    List<int>? ignoration,
  ) {
    return StoreStandardLyrics(
      lyrics.map(StoreLyric.fromRuntime).toList(),
      ignoration,
    );
  }
}

@HiveType(typeId: HiveTypes.storeTranslatedLyricsId)
class StoreTranslatedLyrics {
  @HiveField(0)
  final List<StoreLyric>? lyrics;
  @HiveField(1)
  final List<int>? ignoration;

  const StoreTranslatedLyrics(this.lyrics, this.ignoration);

  List<LyricUnit>? toRuntimeLyrics() {
    return lyrics?.map((store) => store.toRuntime()).toList();
  }

  static StoreTranslatedLyrics fromRuntime(
    List<StandardLyric>? lyrics,
    List<int>? ignoration,
  ) {
    return StoreTranslatedLyrics(
      lyrics?.map(StoreLyric.fromRuntime).toList(),
      ignoration,
    );
  }
}

@HiveType(typeId: HiveTypes.storeRomanLyricsId)
class StoreRomanLyrics {
  @HiveField(0)
  final List<StoreLyric>? lyrics;
  @HiveField(1)
  final List<int>? ignoration;

  const StoreRomanLyrics(this.lyrics, this.ignoration);

  List<LyricUnit>? toRuntimeLyrics() {
    return lyrics?.map((store) => store.toRuntime()).toList();
  }

  static StoreRomanLyrics fromRuntime(
    List<StandardLyric>? lyrics,
    List<int>? ignoration,
  ) {
    return StoreRomanLyrics(
      lyrics?.map(StoreLyric.fromRuntime).toList(),
      ignoration,
    );
  }
}

@HiveType(typeId: HiveTypes.storeWordBasedLyricsId)
class StoreWordBasedLyrics {
  @HiveField(0)
  final List<StoreWordBasedLyric>? lyrics;
  @HiveField(1)
  final List<int>? ignoration;

  const StoreWordBasedLyrics(this.lyrics, this.ignoration);

  List<LyricUnit>? toRuntimeLyrics() {
    return lyrics?.map((store) => store.toRuntime()).toList();
  }

  static StoreWordBasedLyrics fromRuntime(
    List<WordBasedLyric>? lyrics,
    List<int>? ignoration,
  ) {
    return StoreWordBasedLyrics(
      lyrics?.map(StoreWordBasedLyric.fromRuntime).toList(),
      ignoration,
    );
  }
}

@HiveType(typeId: HiveTypes.storeLyricsId)
class StoreLyrics {
  @HiveField(0)
  final StoreStandardLyrics standardLyrics;
  @HiveField(1)
  final StoreTranslatedLyrics translatedLyrics;
  @HiveField(2)
  final StoreRomanLyrics romanLyrics;
  @HiveField(3)
  final StoreWordBasedLyrics? wordBasedLyrics;
  @HiveField(4)
  final int roleCounts;

  const StoreLyrics(
    this.standardLyrics,
    this.translatedLyrics,
    this.romanLyrics,
    this.wordBasedLyrics,
    this.roleCounts,
  );

  LyricsContainer toContainer() {
    return LyricsContainer(
      standardLyrics: standardLyrics.toRuntimeLyrics(),
      translatedLyrics: translatedLyrics.toRuntimeLyrics(),
      romanLyrics: romanLyrics.toRuntimeLyrics(),
      wordBasedLyrics: wordBasedLyrics?.toRuntimeLyrics(),
      dataCount: roleCounts,
      ignoreStandardLyrics: standardLyrics.ignoration,
      ignoreTranslatedLyrics: translatedLyrics.ignoration,
      ignoreRomanLyrics: romanLyrics.ignoration,
      ignoredWordBasedLyrics: wordBasedLyrics?.ignoration,
    );
  }

  static StoreLyrics fromRuntime(LyricsContainer container) {
    return StoreLyrics(
      StoreStandardLyrics.fromRuntime(
        container.standardLyrics
            .map((runtime) => runtime as StandardLyric)
            .toList(),
        container.ignoreStandardLyrics,
      ),
      StoreTranslatedLyrics.fromRuntime(
        container.translatedLyrics
            ?.map((runtime) => runtime as StandardLyric)
            .toList(),
        container.ignoreTranslatedLyrics,
      ),
      StoreRomanLyrics.fromRuntime(
        container.romanLyrics
            ?.map((runtime) => runtime as StandardLyric)
            .toList(),
        container.ignoreRomanLyrics,
      ),
      StoreWordBasedLyrics.fromRuntime(
        container.wordBasedLyrics
            ?.map((runtime) => runtime as WordBasedLyric)
            .toList(),
        container.ignoredWordBasedLyrics,
      ),
      container.dataCount,
    );
  }
}
