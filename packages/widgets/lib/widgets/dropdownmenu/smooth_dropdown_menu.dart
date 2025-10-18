import 'package:flutter/material.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:widgets/widgets/dropdownmenu/smooth_dropdown_menu_item.dart';

import '../../animation/animation_bean.dart';
import '../../animation/animation_combine.dart';
import '../../animation/smooth_scale_animation.dart';

class SmoothDropdownMenu<T> extends StatefulWidget {
  final List<DropdownMenuEntry<T>> entries;
  DropdownMenuEntry<T>? initialEntry;

  final Function(DropdownMenuEntry<T>) onSelected;

  bool? enableSearch;

  final double? outerWidth;
  final double? outerHeight;
  final double? innerWidth;
  final double? innerHeight;
  final double? itemHeight;

  Color? outerColor;

  SmoothDropdownMenu({
    super.key,
    required this.entries,
    this.initialEntry,
    required this.onSelected,
    this.enableSearch,
    this.outerWidth,
    this.outerHeight,
    this.innerWidth,
    this.innerHeight,
    this.itemHeight,
    this.outerColor
  }) {
    enableSearch ??= entries.length >= 10;
  }

  @override
  State<StatefulWidget> createState() => _SmoothDropdownMenuState<T>();
}

class _SmoothDropdownMenuState<T> extends State<SmoothDropdownMenu<T>> {
  List<OptimizedDropdownMenuItem<T>> builtItems = [];
  List<OptimizedDropdownMenuItem<T>> currentItems = [];

  OptimizedDropdownMenuItem<T>? selected;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController(
    keepScrollOffset: true,
  );

  final FocusNode focus = FocusNode();
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;

  AnimationCombination? openAnimationCombination;
  bool animationAdded = false;

  void open() {
    if (overlayEntry != null) {
      return;
    }

    searchController.clear();
    currentItems = List.from(builtItems);

    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final combinationBuilder = AnimationCombinationBuilder();

    overlayEntry = OverlayEntry(
      builder: (context) {
        final animation = SmoothScaleAnimation(
          duration: Duration(milliseconds: 350),
          ratio: ScaleRatio(0.0, 1.0),
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: close,
                child: Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
              Positioned(
                top: position.dy + size.height + 4,
                left: position.dx,
                width:
                    widget.innerWidth ??
                    MediaQuery.of(context).size.width * 0.6,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  child: buildInnerContainer(context),
                ),
              ),
            ],
          ),
        );

        if (!animationAdded) {
          animationAdded = true;
          combinationBuilder.add(animation);
        }
        return animation;
      },
    );

    openAnimationCombination = combinationBuilder.build(
      onReady: (combination) {
        combination.forwardAll();
      },
    );
    openAnimationCombination?.forwardAllCallback = () {
      scrollToSelection();
    };

    Overlay.of(context).insert(overlayEntry!);
  }

  void close() {
    openAnimationCombination?.reverseAll();
    openAnimationCombination?.reverseAllCallback = () {
      overlayEntry?.remove();
      overlayEntry = null;
      searchController.clear();
      openAnimationCombination = null;
      animationAdded = false;
    };
  }

  void onSearch(String content) {
    setState(() {
      if (content.isEmpty) {
        currentItems = List.from(builtItems);
      } else {
        currentItems =
            builtItems.where((item) {
              return item.entry.label.toLowerCase().contains(
                content.toLowerCase(),
              );
            }).toList();
      }

      overlayEntry?.markNeedsBuild();
    });
  }

  void scrollToSelection() {
    if (selected == null) {
      return;
    }
    final index = currentItems.indexWhere((item) {
      if (item == selected) {
        return true;
      }
      return false;
    });
    if (index <= -1) {
      return;
    }

    final itemHeight = widget.itemHeight ?? 48;
    final offset = index * itemHeight;
    scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.fastEaseInToSlowEaseOut,
    );
  }

  void handleFocusChange() {
    if (!focus.hasFocus) {
      close();
    }
  }

  void buildItems() {
    List<OptimizedDropdownMenuItem<T>> result = [];

    for (final entry in widget.entries) {
      final item = OptimizedDropdownMenuItem<T>(
        entry: entry,
        onSelected: (entry) {
          setState(() {
            selected = builtItems.firstWhere((item) {
              return item.entry == entry;
            });
          });
          widget.onSelected(entry);
          close();
        },
        itemHeight: widget.itemHeight ?? 48,
      );
      result.add(item);
    }

    builtItems = result;
    currentItems = builtItems;
  }

  Widget buildInnerContainer(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth:
            widget.innerHeight != null
                ? widget.innerHeight!
                : MediaQuery.of(context).size.height * 0.5,
        maxHeight:
            widget.innerHeight ?? MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: themeData().colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.enableSearch!)
            Padding(
              padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: themeData().colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  hoverColor: themeData().colorScheme.surfaceContainer,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: onSearch,
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  widget.innerHeight != null
                      ? widget.innerHeight! - 70
                      : MediaQuery.of(context).size.height * 0.5 - 70,
            ),
            child: SmoothListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: currentItems.length,
              itemBuilder: (context, index) {
                return currentItems[index];
              },
              controller: scrollController,
              duration: Duration(milliseconds: 500),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOuterContainer(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium ?? TextStyle();
    final fontSize = textStyle.fontSize ?? 14.0;
    final verticalPadding = fontSize * 0.75;
    final minHeight = (fontSize * 1.5) + (verticalPadding * 2);

    return GestureDetector(
      onTap: () {
        if (overlayEntry == null) {
          open();
        } else {
          close();
        }
      },
      child: SmoothContainer(
        constraints: BoxConstraints(
          minWidth: widget.outerWidth ?? 120,
          minHeight: widget.outerHeight ?? minHeight,
        ),
        color: widget.outerColor ?? themeData().colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected != null ? selected!.entry.label : "Select",
                style: themeData().textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    buildItems();
    if (widget.initialEntry != null) {
      final item = builtItems.firstWhere((item) {
        if (item.entry == widget.initialEntry) {
          return true;
        }
        return false;
      });
      selected = item;
    }

    focus.addListener(handleFocusChange);
  }

  @override
  void dispose() {
    focus.removeListener(handleFocusChange);
    focus.dispose();
    searchController.dispose();
    scrollController.dispose();
    close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildOuterContainer(context);
  }
}
