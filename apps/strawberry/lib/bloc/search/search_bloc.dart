import 'package:domain/result/result.dart';
import 'package:domain/usecase/search_usecase.dart';
import 'package:strawberry/bloc/search/get_search_suggestions_event_state.dart';
import 'package:strawberry/bloc/strawberry_bloc.dart';

abstract class SearchEvent {}

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchFailure extends SearchState {
  final Failure failure;

  SearchFailure(this.failure);
}

class SearchBloc extends StrawberryBloc<SearchEvent, SearchState> {
  final SearchUseCase searchUseCase;

  SearchBloc(this.searchUseCase) : super(SearchInitial()) {
    on<AttemptGetSearchSuggestionsEvent>((event, emit) async {
      emit(SearchLoading());
      final data = await searchUseCase.suggestions(event.keyword);
      data.fold(
        (failure) => emit(SearchFailure(failure)),
        (suggestions) =>
            emit(GetSearchSuggestionsSuccess(event.keyword, suggestions)),
      );
    });
  }
}
