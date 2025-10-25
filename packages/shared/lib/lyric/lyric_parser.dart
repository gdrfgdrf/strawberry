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

class CombinedRawLyric extends LyricUnit {
  final String? text;
  final String? translatedText;
  final String? romanText;

  CombinedRawLyric(
    super.position,
    this.text,
    this.translatedText,
    this.romanText,
  );
}

class CombinedWordBasedLyric extends LyricUnit {
  final String? text;
  final String? translatedText;
  final String? romanText;
  final List<WordInfo> wordInfos;
  /// 整句歌词的持续时间
  final Duration duration;

  CombinedWordBasedLyric(
    super.position,
    this.text,
    this.translatedText,
    this.romanText,
    this.wordInfos,
    this.duration,
  );
}

class LyricBreak extends LyricUnit {
  final Duration duration;

  LyricBreak(super.position, this.duration);
}

class LyricParser {
  static List<LyricUnit> parse(String content) {
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

    return units;
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

  static CombinedRawLyric? _parseStandardLyric(String line) {
    final regex = RegExp(r'^\[(\d+):(\d+):(\d+)\](.*)');
    final match = regex.firstMatch(line);

    if (match == null) {
      return null;
    }
    final minutes = int.parse(match.group(1)!);
    final seconds = int.parse(match.group(2)!);
    final hundredths = int.parse(match.group(3)!);
    final text = match.group(4)!.trim();

    final timestamp = (minutes * 60 + seconds) * 1000 + hundredths * 10;

    return CombinedRawLyric(
      Duration(milliseconds: timestamp),
      text.isEmpty ? null : text,
      null,
      null,
    );
  }

  static CombinedWordBasedLyric? _parseWordBasedLyric(String line) {
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

    return CombinedWordBasedLyric(
      Duration(milliseconds: startTime),
      textBuffer.toString(),
      null,
      null,
      wordInfos,
      Duration(milliseconds: duration),
    );
  }
}
