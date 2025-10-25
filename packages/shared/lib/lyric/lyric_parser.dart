import 'dart:convert';

import 'package:shared/string_extension.dart';

abstract class LyricUnit {
  final Duration position;

  LyricUnit(this.position);
}

class WordInfo {
  final String word;
  final Duration position;
  final Duration duration;

  WordInfo(this.word, this.position, this.duration);
}

class JsonLyric extends LyricUnit {
  final List<String> texts;

  JsonLyric(super.position, this.texts);
}

class StandardLyric extends LyricUnit {
  final String? text;

  StandardLyric(super.position, this.text);
}

class WordBasedLyric extends LyricUnit {
  final String? text;
  final List<WordInfo> wordInfos;
  final Duration duration;

  WordBasedLyric(super.position, this.text, this.wordInfos, this.duration);
}

class LyricBreak extends LyricUnit {
  final Duration duration;

  LyricBreak(super.position, this.duration);
}

class CombinedLyric extends LyricUnit {
  final String? text;
  final String? translatedText;
  final String? romanText;
  final WordBasedLyric? wordBasedLyric;

  CombinedLyric(
    super.position,
    this.text,
    this.translatedText,
    this.romanText,
    this.wordBasedLyric,
  );
}

class LyricsContainer {
  final List<LyricUnit> standardLyrics;
  final List<LyricUnit>? translatedLyrics;
  final List<LyricUnit>? romanLyrics;
  final List<LyricUnit>? wordBasedLyrics;
  final int dataCount;

  LyricsContainer({
    required this.standardLyrics,
    required this.translatedLyrics,
    required this.romanLyrics,
    required this.wordBasedLyrics,
    required this.dataCount,
  });

  List<CombinedLyric>? combine() {
    int actualCount = -dataCount;

    for (int i = 0; i < standardLyrics.length; i++) {
      final lyric = standardLyrics[i];
      if (lyric is StandardLyric) {
        if (lyric.text == null) {
          continue;
        }
        actualCount++;
      }
    }

    if (actualCount == 0) {
      return null;
    }

    final cleanedTranslationLyricIndexes = <int>[];
    final cleanedTranslatedLyrics = <LyricUnit>[];
    for (
      int i = 0;
      i < (translatedLyrics?.length ?? <LyricUnit>[].length);
      i++
    ) {
      final lyric = translatedLyrics![i];
      if (lyric is StandardLyric) {
        if (lyric.text == null) {
          cleanedTranslationLyricIndexes.add(i);
          continue;
        }
        cleanedTranslatedLyrics.add(lyric);
      }
    }

    final cleanedRomanLyricIndexes = <int>[];
    final cleanRomanLyrics = <LyricUnit>[];
    for (int i = 0; i < (romanLyrics?.length ?? <LyricUnit>[].length); i++) {
      final lyric = romanLyrics![i];
      if (lyric is StandardLyric) {
        if (lyric.text == null) {
          cleanedRomanLyricIndexes.add(i);
          continue;
        }
        cleanRomanLyrics.add(lyric);
      }
    }

    final cleanedWordBasedLyricIndexes = <int>[];
    final cleanedWordBasedLyrics = <LyricUnit>[];
    for (
      int i = 0;
      i < (wordBasedLyrics?.length ?? <LyricUnit>[].length);
      i++
    ) {
      final lyric = wordBasedLyrics![i];
      if (lyric is WordBasedLyric) {
        if (lyric.text == null) {
          cleanedWordBasedLyricIndexes.add(i);
          continue;
        }
        cleanedWordBasedLyrics.add(lyric);
      }
    }

    int offset = 0;
    int secondaryOffset = 0;
    int translationOffset = 0;
    int romanOffset = 0;
    int wordBasedOffset = 0;

    final combined = <CombinedLyric>[];
    for (int i = 0; i < standardLyrics.length; i++) {
      final lyric = standardLyrics[i];
      if (lyric is! StandardLyric) {
        offset++;
        continue;
      }

      if (i <= dataCount - 1) {
        final combinedLyric = CombinedLyric(
          lyric.position,
          lyric.text,
          null,
          null,
          null,
        );
        combined.add(combinedLyric);
        offset++;
        continue;
      }
      if (lyric.text == null) {
        final combinedLyric = CombinedLyric(
          lyric.position,
          null,
          null,
          null,
          null,
        );
        combined.add(combinedLyric);
        offset++;
        secondaryOffset++;
        continue;
      }

      // LyricUnit? translatedLyric;
      // final translationIndex = i - offset + secondaryOffset;
      // if (!cleanedTranslationLyricIndexes.contains(translationIndex)) {
      //   if (translationIndex >= 0 && cleanedTranslatedLyrics.isNotEmpty) {
      //     print(translationIndex);
      //     print(translationOffset);
      //     print(secondaryOffset);
      //     print(translationIndex - translationOffset - secondaryOffset);
      //     print('-------------------');
      //     translatedLyric =
      //         cleanedTranslatedLyrics[translationIndex - translationOffset - secondaryOffset];
      //   }
      // } else {
      //   translationOffset++;
      // }
      //
      LyricUnit? romanLyric;
      int romanIndex = i - offset + secondaryOffset;
      if (!cleanedRomanLyricIndexes.contains(romanIndex)) {
        if (romanIndex >= 0 && cleanRomanLyrics.isNotEmpty) {
          romanLyric =
              cleanRomanLyrics[romanIndex - romanOffset - secondaryOffset];
        }
      } else {
        romanOffset++;
      }

      final position = lyric.position;

      LyricUnit? translatedLyric;
      if (translatedLyrics != null) {
        for (final lyric in translatedLyrics!) {
          if (lyric.position == position) {
            translatedLyric = lyric;
            break;
          }
        }
      }

      // LyricUnit? romanLyric;
      // if (romanLyrics != null) {
      //   for (final lyric in romanLyrics!) {
      //     if (lyric.position == position) {
      //       romanLyric = lyric;
      //       break;
      //     }
      //   }
      // }

      LyricUnit? wordBasedLyric;
      final wordBasedIndex = i - offset + secondaryOffset;
      if (!cleanedWordBasedLyricIndexes.contains(wordBasedIndex)) {
        if (wordBasedIndex >= 0 && cleanedWordBasedLyrics.isNotEmpty) {
          wordBasedLyric =
              cleanedWordBasedLyrics[wordBasedIndex - wordBasedOffset - secondaryOffset];
        }
      } else {
        wordBasedOffset++;
      }

      final combinedLyric = CombinedLyric(
        lyric.position,
        lyric.text,
        (translatedLyric as StandardLyric?)?.text,
        (romanLyric as StandardLyric?)?.text,
        wordBasedLyric as WordBasedLyric?,
      );
      combined.add(combinedLyric);
    }

    return combined;
  }
}

class LyricParser {
  static LyricsContainer parse(String jsonContent) {
    final json = jsonDecode(jsonContent) as Map<String, dynamic>;

    return LyricsContainer(
      standardLyrics: _parseLyricContent(json["lrc"]?["lyric"] ?? '') ?? [],
      translatedLyrics: _parseLyricContent(json["tlyric"]?["lyric"] ?? ''),
      romanLyrics: _parseLyricContent(json["romalrc"]?["lyric"] ?? ''),
      wordBasedLyrics: _parseYrcContent(json["yrc"]?["lyric"] ?? ''),
      dataCount: json["roles"].length
    );
  }

  static List<LyricUnit>? _parseLyricContent(String content) {
    final lines = content.split('\n');
    final List<LyricUnit> units = [];

    for (final line in lines) {
      if (line.isBlank()) {
        continue;
      }

      if (line.startsWith('{') && line.endsWith('}')) {
        final unit = _parseJsonLine(line);
        if (unit != null) {
          units.add(unit);
        }
        continue;
      }

      if (line.startsWith('[') && line.contains(':') && line.contains(']')) {
        final unit = _parseStandardLyric(line);
        if (unit != null) {
          units.add(unit);
        }
        continue;
      }

      if (line.startsWith('[') && line.contains(',')) {
        final unit = _parseWordBasedLyric(line);
        if (unit != null) {
          units.add(unit);
        }
        continue;
      }
    }

    if (units.isEmpty) {
      return null;
    }
    return units;
  }

  static List<LyricUnit> _parseYrcContent(String content) {
    final lines = content.split('\n');
    final List<LyricUnit> units = [];

    for (final line in lines) {
      if (line.isBlank()) {
        continue;
      }

      if (line.startsWith('[ch:')) {
        continue;
      }

      if (line.startsWith('[') && line.contains(',')) {
        final unit = _parseYrcLine(line);
        if (unit != null) {
          units.add(unit);
        }
        continue;
      }
    }

    return units;
  }

  static WordBasedLyric? _parseYrcLine(String line) {
    final lineRegex = RegExp(r'^\[(\d+),(\d+)\]');
    final lineMatch = lineRegex.firstMatch(line);
    if (lineMatch == null) {
      return null;
    }

    final startTime = int.parse(lineMatch.group(1)!);
    final duration = int.parse(lineMatch.group(2)!);

    final wordRegex = RegExp(r'\((\d+),(\d+),0\)([^()]*)');
    final wordMatches = wordRegex.allMatches(line);

    List<WordInfo> wordInfos = [];
    StringBuffer textBuffer = StringBuffer();

    for (final match in wordMatches) {
      final wordStart = int.parse(match.group(1)!);
      final wordDuration = int.parse(match.group(2)!);
      final word = match.group(3)!;

      wordInfos.add(
        WordInfo(
          word,
          Duration(milliseconds: wordStart),
          Duration(milliseconds: wordDuration),
        ),
      );

      textBuffer.write(word);
    }

    return WordBasedLyric(
      Duration(milliseconds: startTime),
      textBuffer.toString(),
      wordInfos,
      Duration(milliseconds: duration),
    );
  }

  static JsonLyric? _parseJsonLine(String line) {
    if (line.contains('"t"') && line.contains('"c"')) {
      final timestampMatch = RegExp(r'"t":(\d+)').firstMatch(line);
      final textsMatch = RegExp(r'"tx":"([^"]*)"').allMatches(line);

      if (timestampMatch == null) {
        return null;
      }
      final timestamp = int.parse(timestampMatch.group(1)!);
      final texts = textsMatch.map((m) => m.group(1)!).toList();
      return JsonLyric(Duration(milliseconds: timestamp), texts);
    }
    return null;
  }

  static StandardLyric? _parseStandardLyric(String line) {
    if (line.startsWith('[by:')) {
      return null;
    }

    final regex = RegExp(r'\[(\d+):(\d+)\.(\d+)\](.*)');
    final match = regex.firstMatch(line);
    if (match == null) {
      return null;
    }

    final minutes = int.parse(match.group(1)!);
    final seconds = int.parse(match.group(2)!);
    final hundredths = int.parse(match.group(3)!);
    final text = match.group(4)!.trim();

    final timestamp = (minutes * 60 + seconds) * 1000 + hundredths;
    return StandardLyric(
      Duration(milliseconds: timestamp),
      text.isEmpty ? null : text,
    );
  }

  static WordBasedLyric? _parseWordBasedLyric(String line) {
    final lineRegex = RegExp(r'^\[(\d+),(\d+)\]');
    final lineMatch = lineRegex.firstMatch(line);
    if (lineMatch == null) {
      return null;
    }

    final startTime = int.parse(lineMatch.group(1)!);
    final duration = int.parse(lineMatch.group(2)!);

    final wordRegex = RegExp(r'\((\d+),(\d+),0\)([^()]*)');
    final wordMatches = wordRegex.allMatches(line);

    final wordInfos = <WordInfo>[];
    final textBuffer = StringBuffer();

    for (final match in wordMatches) {
      final wordPosition = int.parse(match.group(1)!);
      final wordDuration = int.parse(match.group(2)!);
      final word = match.group(3)!;

      wordInfos.add(
        WordInfo(
          word,
          Duration(milliseconds: wordPosition),
          Duration(milliseconds: wordDuration),
        ),
      );

      textBuffer.write(word);
    }

    return WordBasedLyric(
      Duration(milliseconds: startTime),
      textBuffer.toString(),
      wordInfos,
      Duration(milliseconds: duration),
    );
  }
}
