
import 'package:domain/entity/search_entity.dart';
import 'package:strawberry/bloc/search/search_bloc.dart';

class AttemptGetSearchSuggestionsEvent extends SearchEvent {
  final String keyword;

  AttemptGetSearchSuggestionsEvent(this.keyword);
}

class GetSearchSuggestionsSuccess extends SearchState {
  final String keyword;
  final List<SearchSuggestionEntity> suggestions;

  GetSearchSuggestionsSuccess(this.keyword, this.suggestions);
}