import 'dart:convert';

class SuggestionHighlight {
  final String? text;
  final bool highlighted;

  const SuggestionHighlight(this.text, this.highlighted);

  static SuggestionHighlight parseJson(String string) {
    final json = jsonDecode(string);

    return SuggestionHighlight(json["text"], json["highLighted"] ?? false);
  }
}

class SearchSuggestionEntity {
  final String? keyword;
  final List<SuggestionHighlight> highlights;

  const SearchSuggestionEntity(this.keyword, this.highlights);

  static SearchSuggestionEntity parseJson(String string) {
    final json = jsonDecode(string);
    final highlightsString = json["highLightInfo"] as String?;

    List<SuggestionHighlight> highlights = [];
    if (highlightsString != null && highlightsString.contains("[")) {
      final highlightsJson = jsonDecode(highlightsString);
      for (final highlightJson in highlightsJson ?? []) {
        highlights.add(
          SuggestionHighlight.parseJson(jsonEncode(highlightJson)),
        );
      }
    }

    return SearchSuggestionEntity(json["keyword"], highlights);
  }
}
