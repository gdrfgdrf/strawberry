import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared/platform_extension.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_widget_switch_animation.dart';

class SmoothImage extends StatefulWidget {
  final BorderRadius? borderRadius;

  final Widget? placeholder;
  final List<int>? imageBytes;

  final void Function(bool)? onAnimationStarted;
  final void Function(bool)? onAnimationStopped;

  final VoidCallback? onHovered;
  final VoidCallback? onHoverCancelled;
  final VoidCallback? onClicked;

  final BoxFit? fit;
  final Alignment alignment;
  final double? width;
  final double? height;

  final ValueNotifier<List<int>?>? imageNotifier;

  final bool enableDetectors;

  const SmoothImage({
    super.key,
    this.borderRadius,
    this.placeholder,
    this.imageBytes,
    this.onAnimationStarted,
    this.onAnimationStopped,
    this.onHovered,
    this.onHoverCancelled,
    this.onClicked,
    this.fit,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.imageNotifier,
    this.enableDetectors = true,
  });

  @override
  State<StatefulWidget> createState() => SmoothImageState();
}

class SmoothImageState extends State<SmoothImage> {
  ValueNotifier<List<int>?>? imageNotifier;

  List<int>? imageBytes;
  List<int>? previousImageBytes;

  int animationKey = 0;
  bool animationFLag = false;

  Widget buildMouseRegion(Widget child) {
    if (!widget.enableDetectors) {
      return child;
    }

    if (PlatformExtension.isDesktop) {
      return MouseRegion(
        onEnter: (_) {
          widget.onHovered?.call();
        },
        onExit: (_) {
          widget.onHoverCancelled?.call();
        },
        child: child,
      );
    }
    return child;
  }

  @override
  void initState() {
    imageNotifier = widget.imageNotifier ?? ValueNotifier(null);

    if (widget.imageBytes != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        imageNotifier!.value = widget.imageBytes;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildMouseRegion(
      ValueListenableBuilder(
        valueListenable: imageNotifier!,
        builder: (_, bytes, _) {
          previousImageBytes = imageBytes;
          imageBytes = bytes;

          if (previousImageBytes == imageBytes) {
            return bytes != null
                ? SmoothClipRRect(
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(16),
                  child: Image.memory(
                    Uint8List.fromList(bytes),
                    fit: widget.fit,
                    alignment: widget.alignment,
                    width: widget.width,
                    height: widget.height,
                  ),
                )
                : widget.placeholder ?? SizedBox.shrink();
          }

          final previousImageWidget = SmoothClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            child:
                previousImageBytes != null
                    ? Image.memory(
                      Uint8List.fromList(previousImageBytes!),
                      fit: widget.fit,
                      alignment: widget.alignment,
                      width: widget.width,
                      height: widget.height,
                    )
                    : SmoothContainer(
                      borderRadius: BorderRadius.circular(4),
                      padding: EdgeInsets.all(12),
                      color: themeData().colorScheme.surfaceContainerHigh,
                      child: Icon(Icons.image_outlined),
                    ),
          );

          final imageWidget =
              bytes != null
                  ? SmoothClipRRect(
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(16),
                    child: Image.memory(
                      Uint8List.fromList(bytes),
                      fit: widget.fit,
                      alignment: widget.alignment,
                      width: widget.width,
                      height: widget.height,
                    ),
                  )
                  : widget.placeholder ?? SizedBox.shrink();

          animationKey++;
          final switchAnimation = SmoothWidgetSwitchAnimation(
            key: ValueKey<int>(animationKey),
            before: previousImageWidget,
            after: imageWidget,
            duration: Duration(milliseconds: 500),
          );

          AnimationCombination.newBuilder()
              .add(switchAnimation)
              .build(
                onReady: (animation) {
                  animation.forwardAll();
                },
              );

          if (widget.enableDetectors) {
            return GestureDetector(
              onTap: widget.onClicked,
              child: switchAnimation,
            );
          } else {
            return switchAnimation;
          }
        },
      ),
    );
  }
}
