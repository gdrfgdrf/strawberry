import 'dart:async';

import 'package:domain/entity/search_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/themes.dart';
import 'package:strawberry/bloc/search/get_search_suggestions_event_state.dart';
import 'package:strawberry/bloc/search/search_bloc.dart';
import 'package:strawberry/ui/abstract_page.dart';

class NeteaseSuggestionsSearchAnchor extends AbstractUiWidget {
  final double? maxWidth;
  final double? maxHeight;
  final double? minTextHeight;

  const NeteaseSuggestionsSearchAnchor({
    super.key,
    this.maxWidth,
    this.maxHeight,
    this.minTextHeight,
  });

  @override
  State<StatefulWidget> createState() => _NeteaseSuggestionsSearchAnchorState();
}

class _NeteaseSuggestionsSearchAnchorState
    extends
        AbstractUiWidgetState<NeteaseSuggestionsSearchAnchor, EmptyDelegate> {
  final SearchBloc searchBloc = GetIt.instance.get();
  final SearchController controller = SearchController();

  Completer<List<Widget>>? suggestionsCompleter;

  @override
  EmptyDelegate createDelegate() {
    return EmptyDelegate.instance;
  }

  @override
  List<BlocListener<StateStreamable, dynamic>> blocListeners() {
    return [
      BlocListener(
        bloc: searchBloc,
        listener: (context, state) {
          if (state is GetSearchSuggestionsSuccess) {
            final keyword = controller.text;
            if (keyword != state.keyword) {
              return;
            }

            final suggestionWidgets = <Widget>[];
            for (int i = 0; i < state.suggestions.length; i++) {
              final suggestion = state.suggestions[i];
              Widget? widget;
              if (i == 0) {
                widget = buildSuggestion(suggestion, first: true);
              }
              if (i >= state.suggestions.length - 1) {
                widget = buildSuggestion(suggestion, last: true);
              }
              widget ??= buildSuggestion(suggestion);
              suggestionWidgets.add(widget);
            }

            suggestionsCompleter?.complete(suggestionWidgets);
          }
        },
      ),
    ];
  }

  Widget buildSuggestion(SearchSuggestionEntity suggestion, {bool first = false, bool last = false}) {
    if (first) {
      return Container(
        width: widget.maxWidth ?? 320,
        constraints: BoxConstraints(
            minHeight: widget.minTextHeight ?? 40
        ),
        padding: EdgeInsets.only(top: 4, left: 8, right: 8),
        child: Column(
          children: [
            Text(
              suggestion.keyword ?? "",
              style: TextStyle(fontSize: 24.sp),
            ),
            Divider()
          ],
        ),
      );
    }
    if (last) {
      return Container(
        width: widget.maxWidth ?? 320,
        constraints: BoxConstraints(
            minHeight: widget.minTextHeight ?? 40
        ),
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Column(
          children: [
            Text(
              suggestion.keyword ?? "",
              style: TextStyle(fontSize: 24.sp),
            ),
          ],
        ),
      );
    }

    return Container(
      width: widget.maxWidth ?? 320,
      constraints: BoxConstraints(
          minHeight: widget.minTextHeight ?? 40
      ),
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Column(
        children: [
          Text(
            suggestion.keyword ?? "",
            style: TextStyle(fontSize: 24.sp),
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchBloc.close();
    controller.dispose();
    suggestionsCompleter?.future.ignore();
    suggestionsCompleter = null;
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return SearchAnchor.bar(
      barBackgroundColor: WidgetStatePropertyAll(
        themeData().colorScheme.surfaceContainerLow,
      ),
      viewBackgroundColor: themeData().colorScheme.surfaceContainerLow,
      viewConstraints: BoxConstraints(
        maxWidth: widget.maxWidth ?? 320,
        maxHeight: widget.maxHeight ?? double.infinity,
      ),
      searchController: controller,
      suggestionsBuilder: (context, controller) {
        suggestionsCompleter = Completer();
        return suggestionsCompleter!.future;
      },
      onChanged: (text) {
        searchBloc.add(AttemptGetSearchSuggestionsEvent(text));
      },
    );
  }
}
