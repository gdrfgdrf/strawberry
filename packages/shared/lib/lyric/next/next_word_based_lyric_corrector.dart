
import 'package:shared/lyric/lyric_parser.dart';

class NextWordBasedLyricCorrector {
  static List<CombinedLyric>? correctLyrics(LyricsContainer lyricsContainer) {
    if (lyricsContainer.wordBasedLyrics == null) {
      return null;
    }

    final wordBasedLyrics = [...lyricsContainer.wordBasedLyrics!];

    List<CombinedLyric>? combined = lyricsContainer.combine();
    if (combined == null) {
      return null;
    }
    combined = combined.sublist(lyricsContainer.dataCount, combined.length);

    final rawTexts = <String?>[...combined.map((lyric) => lyric.text)];
    final texts = <String?>[
      ...wordBasedLyrics.map((lyric) => (lyric as WordBasedLyric).text),
    ];
    final translatedTexts = <String?>[];
    final romanTexts = <String?>[];

    final offsets = <int, int>{};
    if (texts.length <= combined.length) {
      int index = 0;

      for (final lyric in combined) {
        final rawText = lyric.text;
        if (rawText == null) {
          if (!offsets.containsKey(index)) {
            offsets[index] = 1;
          } else {
            offsets[index] = offsets[index]! + 1;
          }

          translatedTexts.add(lyric.translatedText);
          romanTexts.add(lyric.romanText);
          index++;
          continue;
        }

        if (!texts.contains(rawText)) {
          translatedTexts.add(lyric.translatedText);
          romanTexts.add(lyric.romanText);
          index++;
          continue;
        }

        translatedTexts.add(lyric.translatedText);
        romanTexts.add(lyric.romanText);
        index++;
      }
    } else {
      for (int i = 0; i < texts.length; i++) {
        final text = texts[i];
        if (text == null) {
          translatedTexts.add(null);
          romanTexts.add(null);
          continue;
        }

        final rawIndex = rawTexts.indexOf(text);
        if (rawIndex <= -1) {
          bool found = false;

          for (final lyric in combined) {
            if (lyric.text?.contains(text) == true) {
              translatedTexts.add(lyric.translatedText);
              romanTexts.add(lyric.romanText);
              found = true;
              break;
            }
          }
          if (!found) {
            translatedTexts.add(null);
            romanTexts.add(null);
          }

          continue;
        }

        final lyric = combined[rawIndex];
        translatedTexts.add(lyric.translatedText);
        romanTexts.add(lyric.romanText);
      }
    }

    int cumulativeOffset = 0;
    final result = <CombinedLyric>[];
    for (int i = 0; i < texts.length; i++) {
      final text = texts[i];

      int offset = 0;
      if (offsets.containsKey(i + cumulativeOffset)) {
        offset = offsets[i + cumulativeOffset]!;
      }
      cumulativeOffset = cumulativeOffset + offset;

      final translatedText = translatedTexts[i + cumulativeOffset];
      final romanText = romanTexts[i + cumulativeOffset];
      final wordBasedLyric = wordBasedLyrics[i] as WordBasedLyric;
      result.add(
        CombinedLyric(
          wordBasedLyric.position,
          text,
          translatedText,
          romanText,
          wordBasedLyric,
        ),
      );
    }

    return result;
  }
}