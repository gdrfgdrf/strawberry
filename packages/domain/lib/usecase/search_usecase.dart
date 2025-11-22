import 'package:dartz/dartz.dart';
import 'package:domain/entity/search_entity.dart';
import 'package:domain/repository/search_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/strawberry_usecase.dart';

abstract class SearchUseCase {
  Future<Either<Failure, List<SearchSuggestionEntity>>> suggestions(
    String keyword,
  );
}

class SearchUseCaseImpl extends StrawberryUseCase implements SearchUseCase {
  final AbstractSearchRepository searchRepository;

  SearchUseCaseImpl(this.searchRepository);

  @override
  Future<Either<Failure, List<SearchSuggestionEntity>>> suggestions(
    String keyword,
  ) async {
    serviceLogger!.trace("getting search suggestions, keyword: $keyword");

    try {
      final suggestions = await searchRepository.suggestions(keyword);
      return Right(suggestions);
    } catch (e, s) {
      serviceLogger!.error(
        "getting search suggestions error, keyword: $keyword: $e\n$s",
      );
      return Left(Failure(e, s));
    }
  }
}
