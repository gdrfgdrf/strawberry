import 'dart:async';
import 'dart:convert';

import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/task_chain.dart';
import 'package:domain/entity/search_entity.dart';
import 'package:domain/repository/search_repository.dart';
import 'package:get_it/get_it.dart';

import 'exception/api_service_exception.dart';

class SearchRepositoryImpl extends AbstractSearchRepository {
  @override
  Future<List<SearchSuggestionEntity>> suggestions(String keyword) {
    final completer = Completer<List<SearchSuggestionEntity>>();
    final endpoint = GetIt.instance.get<UrlProvider>().searchSuggestion(
      keyword,
    );
    final taskChain = TaskChain();

    taskChain
        .stringNetwork(() => endpoint)
        .onComplete((response, _) {
          final parsedResponse = jsonDecode(response);
          if (parsedResponse["code"] != 200) {
            final exception = ApiServiceException(
              parsedResponse["message"] ?? parsedResponse.toString(),
            );
            completer.completeError(exception, StackTrace.current);
            return;
          }

          final suggests = parsedResponse["suggests"];
          if (suggests is! List) {
            final exception = ApiServiceException(
              "'suggests' is not a list: $suggests",
            );
            completer.completeError(exception, StackTrace.current);
            return;
          }

          final result = <SearchSuggestionEntity>[];
          for (final suggestion in suggests) {
            result.add(
              SearchSuggestionEntity.parseJson(jsonEncode(suggestion)),
            );
          }

          completer.complete(result);
        })
        .globalOnError((_, e, s) {
          completer.completeError(e, s);
        })
        .run();

    return completer.future;
  }
}
