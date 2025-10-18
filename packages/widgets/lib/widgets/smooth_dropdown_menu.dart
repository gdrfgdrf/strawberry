import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:widgets/animation/animation_bean.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_expand_animation.dart';
import 'package:widgets/animation/smooth_fade_animation.dart';

typedef SearchFilter = bool Function(String);
typedef SelectionChangedCallback = void Function(int, SmoothDropdownEntry);

class SmoothDropdownEntry {
  final Widget? content;
  final Widget? leading;
  final Widget? trailing;

  final SearchFilter? searchFilter;

  /// define it if you dont want to follow the entryContentPadding
  final EdgeInsets? contentPadding;

  /// define it if you dont want to follow the entryLeadingPadding
  final EdgeInsets? leadingPadding;

  /// define it if you dont want to follow the entryTrailingPadding
  final EdgeInsets? trailingPadding;

  const SmoothDropdownEntry({
    this.content,
    this.leading,
    this.trailing,
    this.searchFilter,
    this.contentPadding,
    this.leadingPadding,
    this.trailingPadding,
  });
}

class SmoothDropdownMenu extends StatefulWidget {
  final double? outerWidth;
  final double? outerHeight;

  final double? overlayWidth;
  final double? overlayHeight;

  final double? entryWidth;

  /// 48
  final double? entryHeight;

  final double? searchBarWidth;

  /// 48
  final double? searchBarHeight;

  /// zero
  final EdgeInsets? entryContentPadding;

  /// left 6.0
  final EdgeInsets? entryLeadingPadding;

  /// right 6.0
  final EdgeInsets? entryTrailingPadding;

  /// circular 16
  final BorderRadius? outerBorderRadius;

  /// circular 16
  final BorderRadius? overlayBorderRadius;

  /// circular 16
  final BorderRadius? searchBarBorderRadius;

  /// surfaceContainerLow
  final Color? outerColor;

  /// surfaceContainerHigh
  final Color? overlayColor;

  /// surfaceContainerLow
  final Color? searchBarColor;

  /// 1.0
  final double? outerOpacity;

  /// 0.8
  final double? overlayOpacity;

  /// 0.0
  final double? outerBlurX;

  /// 0.0
  final double? outerBlurY;

  /// 10.0
  final double? overlayBlurX;

  /// 10.0
  final double? overlayBlurY;

  /// symmetric 4.0, 2.0
  final EdgeInsets? outerPadding;

  /// symmetric 4.0, 2.0
  final EdgeInsets? overlayPadding;

  /// symmetric 4.0, 6.0
  final EdgeInsets? searchBarMargin;

  /// symmetric 1.0, 2.0
  final EdgeInsets? searchBarPadding;

  /// 500ms
  final Duration? expandDuration;

  final List<SmoothDropdownEntry> entries;

  /// false
  final bool enableSearch;

  final SelectionChangedCallback? onSelection;

  /// 0
  final int initialIndex;

  const SmoothDropdownMenu({
    super.key,
    this.outerWidth,
    this.outerHeight,
    this.overlayWidth,
    this.overlayHeight,
    this.entryWidth,
    this.entryHeight,
    this.searchBarWidth,
    this.searchBarHeight,
    this.entryContentPadding,
    this.entryLeadingPadding,
    this.entryTrailingPadding,
    this.outerBorderRadius,
    this.overlayBorderRadius,
    this.searchBarBorderRadius,
    this.outerColor,
    this.overlayColor,
    this.searchBarColor,
    this.outerOpacity,
    this.overlayOpacity,
    this.outerBlurX,
    this.outerBlurY,
    this.overlayBlurX,
    this.overlayBlurY,
    this.outerPadding,
    this.overlayPadding,
    this.searchBarMargin,
    this.searchBarPadding,
    this.expandDuration,
    required this.entries,
    this.enableSearch = false,
    this.onSelection,
    this.initialIndex = 0
  });

  @override
  State<StatefulWidget> createState() => _SmoothDropdownMenuState();
}

class _SmoothDropdownMenuState extends State<SmoothDropdownMenu>
    with TickerProviderStateMixin {
  int previousEntryIndex = 0;
  ValueNotifier<int>? entrySelectionNotifier;

  GlobalKey outerKey = GlobalKey();
  bool expanded = false;
  OverlayEntry? overlayEntry;
  AnimationCombination? expandAnimation;

  Rect? outerRect;
  Rect? overlayRect;

  Widget combineEntry(SmoothDropdownEntry entry) {
    final defaultContentPadding = widget.entryContentPadding ?? EdgeInsets.zero;
    final defaultLeadingPadding =
        widget.entryLeadingPadding ?? EdgeInsets.only(left: 6.0);
    final defaultTrailingPadding =
        widget.entryTrailingPadding ?? EdgeInsets.only(right: 6.0);

    return ConstraintLayout(
      children: [
        (entry.leading ?? SizedBox.shrink()).applyConstraint(
          top: parent.top,
          bottom: parent.bottom,
          left: parent.left,
          margin: entry.leadingPadding ?? defaultLeadingPadding,
        ),
        (entry.content ?? SizedBox.shrink()).applyConstraint(
          top: parent.top,
          bottom: parent.bottom,
          left: parent.left,
          right: parent.right,
          margin: entry.contentPadding ?? defaultContentPadding,
        ),
        (entry.trailing ?? SizedBox.shrink()).applyConstraint(
          top: parent.top,
          bottom: parent.bottom,
          right: parent.right,
          margin: entry.trailingPadding ?? defaultTrailingPadding,
        ),
      ],
    );
  }

  void showOverlay() {
    expanded = true;

    final renderObject =
        outerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderObject == null) {
      expanded = false;
      return;
    }

    final offset = renderObject.localToGlobal(Offset.zero);
    final outerSize = renderObject.size;
    final outerWidth = outerSize.width;
    final outerHeight = outerSize.height;

    outerRect = Rect.fromLTWH(offset.dx, offset.dy, outerWidth, outerHeight);

    final overlayLeft = offset.dx;
    final overlayTop = offset.dy + outerHeight + 4;
    final overlayWidth = widget.overlayWidth ?? outerWidth;
    final overlayHeight = widget.overlayHeight ?? outerHeight + 120;
    overlayRect = Rect.fromLTWH(
      overlayLeft,
      overlayTop,
      overlayWidth,
      overlayHeight,
    );

    overlayEntry = OverlayEntry(
      builder: (context) {
        final animation = SmoothExpandAnimation(
          left: offset.dx,
          top: offset.dy + outerHeight + 4,
          width: widget.overlayWidth ?? outerWidth,
          height: widget.overlayHeight ?? outerHeight + 120,
          axis: AnimationDirection.verticalTopToBottom,
          duration: widget.expandDuration ?? Duration(milliseconds: 500),
          child: Material(
            color: Colors.transparent,
            child: buildOverlay(outerWidth, outerHeight + 120),
          ),
        );

        AnimationCombination.newBuilder()
            .add(animation)
            .build(
              onReady: (animation) {
                expandAnimation = animation;
                animation.forwardAll();
              },
            );

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  final pos = details.globalPosition;
                  final inOuter = outerRect?.contains(pos) ?? false;
                  final inOverlay = overlayRect?.contains(pos) ?? false;

                  if (inOverlay) {
                    return;
                  }
                  if (inOuter) {
                    toggleOverlay();
                    return;
                  }
                  hideOverlay();
                  return;
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            animation,
          ],
        );
      },
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  void hideOverlay() {
    expanded = false;

    if (overlayEntry != null) {
      expandAnimation?.reverseAllCallback = () {
        overlayEntry?.remove();
        overlayEntry = null;
        expandAnimation = null;
      };
      expandAnimation?.reverseAll();
    }

    outerRect = null;
    overlayRect = null;
  }

  void forceHideOverlay() {
    expanded = false;
    expandAnimation = null;
    try {
      overlayEntry?.remove();
    } catch (e) {
      /// ignored
    }
    overlayEntry = null;

    outerRect = null;
    overlayRect = null;
  }

  void toggleOverlay() {
    if (expanded) {
      hideOverlay();
      return;
    }
    showOverlay();
  }

  Widget buildSearchBar(double auxiliaryWidth) {
    double realWidth = widget.searchBarWidth ?? auxiliaryWidth;
    double realHeight = widget.searchBarHeight ?? 48;

    final iconId = ConstraintId("icon");

    return Padding(
      padding:
          widget.searchBarMargin ??
          EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      child: SmoothContainer(
        width: realWidth,
        height: realHeight,
        padding:
        widget.searchBarPadding ??
            EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
        color:
        widget.searchBarColor ??
            themeData().colorScheme.surfaceContainerLow,
        borderRadius:
        widget.searchBarBorderRadius ?? BorderRadius.circular(16),
        child: ConstraintLayout(
          children: [
            Icon(
              Icons.search_rounded,
              color: themeData().colorScheme.onSurfaceVariant,
            ).applyConstraint(
              id: iconId,
              top: parent.top,
              bottom: parent.bottom,
              left: parent.left,
            ),
            Padding(
              padding: EdgeInsets.only(right: themeData().iconTheme.size ?? 24),
              child: TextField(
                decoration: InputDecoration(border: InputBorder.none),
                textAlignVertical: TextAlignVertical.top,
              ),
            ).applyConstraint(
              top: parent.top,
              bottom: parent.bottom,
              left: iconId.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOverlay(double auxiliaryWidth, double auxiliaryHeight) {
    double realWidth = widget.overlayWidth ?? auxiliaryWidth;
    double realHeight = widget.overlayHeight ?? auxiliaryHeight;

    int itemCount = widget.entries.length;
    if (widget.enableSearch) {
      itemCount++;
    }

    return Opacity(
      opacity: widget.overlayOpacity ?? 0.95,
      child: SmoothClipRRect(
        borderRadius: widget.overlayBorderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.overlayBlurX ?? 0.0,
            sigmaY: widget.overlayBlurY ?? 0.0,
          ),
          child: SmoothContainer(
            padding:
                widget.overlayPadding ??
                EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            width: realWidth,
            height: realHeight,
            borderRadius:
                widget.overlayBorderRadius ?? BorderRadius.circular(16),
            color:
                widget.overlayColor ??
                themeData().colorScheme.surfaceContainerHigh,
            child: SmoothListView.builder(
              duration: Duration(milliseconds: 500),
              itemCount: itemCount,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (widget.enableSearch && index == 0) {
                  return buildSearchBar(auxiliaryWidth);
                }
                int targetIndex = index;
                if (widget.enableSearch) {
                  targetIndex--;
                }

                final entry = widget.entries[targetIndex];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius:
                        widget.overlayBorderRadius ?? BorderRadius.circular(16),
                    onTap: () {
                      hideOverlay();
                      entrySelectionNotifier!.value = targetIndex;

                      widget.onSelection?.call(targetIndex, entry);
                    },
                    child: SmoothContainer(
                      width: widget.entryWidth,
                      height: widget.entryHeight ?? 48,
                      child: combineEntry(entry),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOuter() {
    return GestureDetector(
      onTap: () {
        toggleOverlay();
      },
      child: Opacity(
        key: outerKey,
        opacity: widget.outerOpacity ?? 1.0,
        child: SmoothClipRRect(
          borderRadius: widget.outerBorderRadius ?? BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.outerBlurX ?? 0.0,
              sigmaY: widget.outerBlurY ?? 0.0,
            ),
            child: SmoothContainer(
              padding:
                  widget.outerPadding ??
                  EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              width: widget.outerWidth,
              height: widget.outerHeight,
              borderRadius:
                  widget.outerBorderRadius ?? BorderRadius.circular(16),
              color:
                  widget.outerColor ??
                  themeData().colorScheme.surfaceContainerLow,
              child: ValueListenableBuilder(
                valueListenable: entrySelectionNotifier!,
                builder: (context, entryIndex, _) {
                  final entry = widget.entries[entryIndex];
                  final previousEntry = widget.entries[previousEntryIndex];

                  AnimationDirection fadeInDirection =
                      AnimationDirection.verticalTopToBottom;
                  AnimationDirection fadeOutDirection =
                      AnimationDirection.verticalTopToBottom;
                  if (entryIndex >= previousEntryIndex) {
                    fadeInDirection = AnimationDirection.verticalBottomToTop;
                    fadeOutDirection = AnimationDirection.verticalBottomToTop;
                  }
                  previousEntryIndex = entryIndex;

                  final controller = AnimationController(
                    vsync: this,
                    duration: Duration(milliseconds: 500),
                  );

                  final fadeIn = SmoothFadeInAnimation(
                    duration: Duration(milliseconds: 500),
                    direction: fadeInDirection,
                    child: combineEntry(entry),
                  ).buildAnimatedWidget(context, controller);

                  final fadeOut = SmoothFadeOutAnimation(
                    duration: Duration(milliseconds: 500),
                    direction: fadeOutDirection,
                    child: combineEntry(previousEntry),
                  ).buildAnimatedWidget(context, controller);

                  controller.forward();

                  return ConstraintLayout(
                    children: [
                      fadeIn.applyConstraint(
                        top: parent.top,
                        bottom: parent.bottom,
                        left: parent.left,
                        right: parent.right,
                      ),
                      fadeOut.applyConstraint(
                        top: parent.top,
                        bottom: parent.bottom,
                        left: parent.left,
                        right: parent.right,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    entrySelectionNotifier = ValueNotifier(widget.initialIndex);
  }

  @override
  void dispose() {
    entrySelectionNotifier?.dispose();
    forceHideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    forceHideOverlay();
    return buildOuter();
  }
}
