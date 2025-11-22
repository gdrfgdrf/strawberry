
import 'package:domain/entity/search_entity.dart';

abstract class AbstractSearchRepository {
  Future<List<SearchSuggestionEntity>> suggestions(String keyword);
}