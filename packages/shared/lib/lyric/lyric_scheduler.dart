import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:shared/lyric/lyric_parser.dart';

void main() async {
  final lyricsJson = {};
  final lyrics = LyricParser.parse(jsonEncode(lyricsJson));
  final combined = lyrics.combine()!;

  for (final combination in combined) {
    print(
      "${combination.text} | ${combination.translatedText} | ${combination.romanText} | ${combination.position} | ${combination.wordBasedLyric?.text} | ${combination.wordBasedLyric?.position} | ${combination.wordBasedLyric?.duration}",
    );
  }

  final positionStream = StreamController<Duration>();
  final scheduler = LyricScheduler(combined, positionStream.stream);
  scheduler.ignoreNullStandardText = true;
  scheduler.start();

  int currentPosition = 0;
  scheduler.lyricStream.listen((data) {
    if (data == null) {
      return;
    }
    final lyric = data.lyric;

    if (data is WordBasedLyricStreamData) {
      if (lyric is CombinedLyric) {
        print(
          "[$currentPosition ms] Combined - 行: ${data.index} | 文本: ${lyric.wordBasedLyric?.text} | 当前字: ${data.wordInfo?.word}",
        );
      }
      if (lyric is WordBasedLyric) {
        print(
          '[$currentPosition ms] 逐字歌词 - 行: ${data.index} | 文本: ${lyric.text} | 当前字: ${data.wordInfo?.word}',
        );
      }
      return;
    }

    if (lyric is JsonLyric) {
      print(
        '[$currentPosition ms] Json - 行: ${data.index} | 文本: ${lyric.texts.join()}',
      );
    }
    if (lyric is StandardLyric) {
      print(
        '[$currentPosition ms] 标准歌词 - 行: ${data.index} | 文本: ${lyric.text}',
      );
    }
    if (lyric is CombinedLyric) {
      print(
        '[$currentPosition ms] Combined - 行: ${data.index} | 文本: ${lyric.text}',
      );
    }
  });

  positionStream.add(Duration(milliseconds: 0));
  final timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
    currentPosition += 50;
    positionStream.add(Duration(milliseconds: currentPosition));
  });

  await Future.delayed(const Duration(minutes: 10));
  timer.cancel();
  positionStream.close();
  scheduler.dispose();
}

class LyricStreamData {
  final int index;
  final LyricUnit lyric;

  LyricStreamData(this.index, this.lyric);
}

class WordBasedLyricStreamData extends LyricStreamData {
  final WordInfo? wordInfo;

  WordBasedLyricStreamData(super.index, super.lyric, {this.wordInfo});
}

class LyricScheduler {
  final List<CombinedLyric> _lyrics;
  final Stream<Duration> positionStream;
  bool ignoreNullStandardText = false;

  final BehaviorSubject<LyricStreamData?> lyricStream = BehaviorSubject.seeded(
    null,
  );

  StreamSubscription? _positionSubscription;
  int _currentLyricIndex = -1;
  WordInfo? _currentWordInfo;

  LyricScheduler(this._lyrics, this.positionStream);

  void start() {
    _positionSubscription = positionStream.listen(_handlePositionUpdate);
  }

  void stop() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _handlePositionUpdate(Duration position) {
    final lyricDatas = _findCurrentLyric(position);
    if (lyricDatas != null) {
      for (final lyricData in lyricDatas) {
        lyricStream.add(lyricData);
      }
    }
  }

  List<LyricStreamData>? _findCurrentLyric(Duration position) {
    final effectiveLyrics = _getEffectiveLyrics();
    if (effectiveLyrics.isEmpty) {
      return null;
    }

    final currentLines = _findCurrentLine(position, effectiveLyrics);
    if (currentLines == null) {
      _currentLyricIndex = -1;
      _currentWordInfo = null;
      return null;
    }

    final results = <LyricStreamData>[];
    for (final currentLine in currentLines) {
      final currentIndex = currentLine.$1;
      final currentUnit = currentLine.$2;

      WordInfo? currentWordInfo;
      if (currentUnit.wordBasedLyric != null) {
        currentWordInfo = _findCurrentWord(
          position,
          currentUnit.wordBasedLyric!,
        );
      }

      if (currentIndex == _currentLyricIndex &&
          currentWordInfo == _currentWordInfo) {
        continue;
      }

      _currentLyricIndex = currentIndex;
      _currentWordInfo = currentWordInfo;

      if (currentUnit.wordBasedLyric != null && currentWordInfo != null) {
        results.add(
          WordBasedLyricStreamData(
            currentIndex,
            currentUnit,
            wordInfo: currentWordInfo,
          ),
        );
        continue;
      }

      results.add(LyricStreamData(currentIndex, currentUnit));
    }

    return results;
  }

  List<(int, CombinedLyric)> _getEffectiveLyrics() {
    final result = <(int, CombinedLyric)>[];
    for (int i = 0; i < _lyrics.length; i++) {
      final unit = _lyrics[i];
      result.add((i, unit));
    }
    return result;
  }

  List<(int, CombinedLyric)>? _findCurrentLine(
    Duration position,
    List<(int, CombinedLyric)> effectiveLyrics,
  ) {
    final results = <(int, CombinedLyric)>[];

    for (int i = 0; i < effectiveLyrics.length; i++) {
      final previous = i <= 0 ? null : effectiveLyrics[i - 1];
      final current = effectiveLyrics[i];
      final next =
          i + 1 < effectiveLyrics.length ? effectiveLyrics[i + 1] : null;

      final previousUnit = previous?.$2;
      final currentUnit = current.$2;
      final nextUnit = next?.$2;

      if (currentUnit.wordBasedLyric == null) {
        if (currentUnit.text == null && ignoreNullStandardText) {
          continue;
        }

        if (nextUnit != null) {
          if (position >= currentUnit.position &&
              position <= nextUnit.position) {
            results.add(current);
          }
        }
      } else {
        if (previousUnit != null && previousUnit.wordBasedLyric == null) {
          final currentPosition = currentUnit.wordBasedLyric!.position;

          if (currentPosition <= previousUnit.position) {
            final endTime1 =
                currentUnit.position + currentUnit.wordBasedLyric!.duration;
            final endTime2 =
                currentUnit.wordBasedLyric!.position +
                currentUnit.wordBasedLyric!.duration;
            final endTime = Duration(
              milliseconds: min(
                endTime1.inMilliseconds,
                endTime2.inMilliseconds,
              ),
            );

            if (position >= currentUnit.position && position <= endTime) {
              results.add(current);
            }

            continue;
          }
        }

        final endTime =
            currentUnit.wordBasedLyric!.position +
            currentUnit.wordBasedLyric!.duration;

        if (currentUnit.wordBasedLyric != null) {
          if (position > currentUnit.wordBasedLyric!.position &&
              position < endTime) {
            results.add(current);
          }
        }
      }
    }
    if (results.isNotEmpty) {
      return results;
    }

    if (effectiveLyrics.isNotEmpty) {
      final last = effectiveLyrics.last;
      final lastUnit = last.$2;
      if (position >= lastUnit.position) {
        return [last];
      }
    }

    return null;
  }

  WordInfo? _findCurrentWord(Duration position, WordBasedLyric lyricLine) {
    if (lyricLine.wordInfos == null) {
      return null;
    }

    for (final wordInfo in lyricLine.wordInfos!) {
      final wordEndPosition = wordInfo.position + wordInfo.duration;

      if (position >= wordInfo.position && position <= wordEndPosition) {
        return wordInfo;
      }
    }

    final lineEndTime = lyricLine.position + lyricLine.duration;
    if (position >= lyricLine.position &&
        position < lineEndTime &&
        lyricLine.wordInfos!.isNotEmpty) {
      return lyricLine.wordInfos!.last;
    }

    return null;
  }

  void seekTo(Duration position) {
    _currentLyricIndex = -1;
    _currentWordInfo = null;
    _handlePositionUpdate(position);
  }

  void dispose() {
    stop();
    lyricStream.close();
  }
}
