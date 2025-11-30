
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

    if (texts.length <= combined.length) {
      for (final lyric in combined) {
        final rawText = lyric.text;
        if (rawText == null) {
          continue;
        }

        if (!texts.contains(rawText)) {
          translatedTexts.add(lyric.translatedText);
          romanTexts.add(lyric.romanText);
          continue;
        }

        translatedTexts.add(lyric.translatedText);
        romanTexts.add(lyric.romanText);
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

    final result = <CombinedLyric>[];
    for (int i = 0; i < texts.length; i++) {
      final text = texts[i];
      final translatedText = translatedTexts[i];
      final romanText = romanTexts[i];
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