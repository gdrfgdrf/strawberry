import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_widget_switch_animation.dart';

class NextSmoothImage extends StatefulWidget {
  final Stream<ImageProvider?> imageProviderStream;

  final double? width;
  final double? height;
  final double? iconSize;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  final VoidCallback? onHovered;
  final VoidCallback? onHoverCancelled;
  final VoidCallback? onClicked;
  final bool? enableGestureDetection;

  StreamController<ImageProvider?>? _selfStreamController;
  ValueNotifier<List<int>?>? _providedNotifier;

  static NextSmoothImage memory({
    Key? key,
    required Uint8List bytes,
    double? width,
    double? height,
    double? iconSize,
    BorderRadius? borderRadius,
    Widget? placeholder,
    VoidCallback? onHovered,
    VoidCallback? onHoverCancelled,
    VoidCallback? onClicked,
    bool? enableGestureDetection,
  }) {
    return NextSmoothImage(
      key: key,
      imageProviderStream: Stream.value(MemoryImage(bytes)),
      width: width,
      height: height,
      iconSize: iconSize,
      borderRadius: borderRadius,
      placeholder: placeholder,
      onHovered: onHovered,
      onHoverCancelled: onHoverCancelled,
      onClicked: onClicked,
      enableGestureDetection: enableGestureDetection,
    );
  }

  static NextSmoothImage streamController({
    Key? key,
    required void Function(StreamController<ImageProvider?>) onStreamController,
    double? width,
    double? height,
    double? iconSize,
    BorderRadius? borderRadius,
    Widget? placeholder,
    VoidCallback? onHovered,
    VoidCallback? onHoverCancelled,
    VoidCallback? onClicked,
    bool? enableGestureDetection,
  }) {
    final streamController = BehaviorSubject<ImageProvider?>();
    onStreamController(streamController);

    return NextSmoothImage(
      key: key,
      imageProviderStream: streamController.stream,
      width: width,
      height: height,
      iconSize: iconSize,
      borderRadius: borderRadius,
      placeholder: placeholder,
      onHovered: onHovered,
      onHoverCancelled: onHoverCancelled,
      onClicked: onClicked,
      enableGestureDetection: enableGestureDetection,
    ).._selfStreamController = streamController;
  }

  static NextSmoothImage bytesStream({
    Key? key,
    required Stream<List<int>?> stream,
    double? width,
    double? height,
    double? iconSize,
    BorderRadius? borderRadius,
    Widget? placeholder,
    VoidCallback? onHovered,
    VoidCallback? onHoverCancelled,
    VoidCallback? onClicked,
    bool? enableGestureDetection,
  }) {
    return streamController(
      key: key,
      width: width,
      height: height,
      iconSize: iconSize,
      borderRadius: borderRadius,
      placeholder: placeholder,
      onHovered: onHovered,
      onHoverCancelled: onHoverCancelled,
      onClicked: onClicked,
      enableGestureDetection: enableGestureDetection,
      onStreamController: (controller) {
        controller.onListen = () {
          final subscription = stream.listen((bytes) {
            if (bytes == null) {
              controller.add(null);
              return;
            }

            controller.add(MemoryImage(Uint8List.fromList(bytes)));
          });

          controller.onCancel = () {
            subscription.cancel();
          };
        };
      },
    );
  }

  static NextSmoothImage typedBytesStream({
    Key? key,
    required Stream<Uint8List?> stream,
    double? width,
    double? height,
    double? iconSize,
    BorderRadius? borderRadius,
    Widget? placeholder,
    VoidCallback? onHovered,
    VoidCallback? onHoverCancelled,
    VoidCallback? onClicked,
    bool? enableGestureDetection,
  }) {
    return streamController(
      onStreamController: (controller) {
        controller.onListen = () {
          final subscription = stream.listen((bytes) {
            if (bytes == null) {
              controller.add(null);
              return;
            }

            controller.add(MemoryImage(bytes));
          });

          controller.onCancel = () {
            subscription.cancel();
          };
        };
      },
    );
  }

  static NextSmoothImage notifier({
    Key? key,
    required ValueNotifier<List<int>?> notifier,
    double? width,
    double? height,
    double? iconSize,
    BorderRadius? borderRadius,
    Widget? placeholder,
    VoidCallback? onHovered,
    VoidCallback? onHoverCancelled,
    VoidCallback? onClicked,
    bool? enableGestureDetection,
  }) {
    return streamController(
      key: key,
      width: width,
      height: height,
      iconSize: iconSize,
      borderRadius: borderRadius,
      placeholder: placeholder,
      onHovered: onHovered,
      onHoverCancelled: onHoverCancelled,
      onClicked: onClicked,
      onStreamController: (streamController) {},
      enableGestureDetection: enableGestureDetection,
    ).._providedNotifier = notifier;
  }

  static NextSmoothImage typedNotifier({
    Key? key,
    required ValueNotifier<Uint8List?> notifier,
    double? width,
    double? height,
    double? iconSize,
    BorderRadius? borderRadius,
    Widget? placeholder,
    VoidCallback? onHovered,
    VoidCallback? onHoverCancelled,
    VoidCallback? onClicked,
    bool? enableGestureDetection,
  }) {
    return streamController(
      key: key,
      width: width,
      height: height,
      iconSize: iconSize,
      borderRadius: borderRadius,
      placeholder: placeholder,
      onHovered: onHovered,
      onHoverCancelled: onHoverCancelled,
      onClicked: onClicked,
      onStreamController: (streamController) {},
      enableGestureDetection: enableGestureDetection,
    ).._providedNotifier = notifier;
  }

  NextSmoothImage({
    super.key,
    required this.imageProviderStream,
    this.width,
    this.height,
    this.iconSize,
    this.borderRadius,
    this.placeholder,
    this.onHovered,
    this.onHoverCancelled,
    this.onClicked,
    this.enableGestureDetection,
  });

  @override
  State<StatefulWidget> createState() => _NextSmoothImageState();
}

class _NextSmoothImageState extends State<NextSmoothImage> {
  ImageProvider? _previousImageProvider;
  ImageProvider? _currentImageProvider;

  void onNotifierChanged() {
    if (widget._selfStreamController == null) {
      return;
    }

    final bytes = widget._providedNotifier?.value;
    if (bytes == null) {
      widget._selfStreamController!.add(null);
      return;
    }
    widget._selfStreamController!.add(MemoryImage(Uint8List.fromList(bytes)));
  }

  Widget buildDefaultPlaceholder() {
    return Opacity(
      opacity: 0.8,
      child: SmoothContainer(
        width: widget.width,
        height: widget.height,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
        color: themeData().colorScheme.surfaceContainer,
        child: Icon(
          Icons.image_outlined,
          size: widget.iconSize,
          color: themeData().colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget buildImage(ImageProvider? imageProvider) {
    if (imageProvider == null) {
      if (widget.placeholder != null) {
        return widget.placeholder!;
      }
      return buildDefaultPlaceholder();
    }
    return Image(
      image: imageProvider,
      width: widget.width,
      height: widget.height,
    );
  }

  Widget combine(ImageProvider? current, ImageProvider? previous) {
    final actualBorderRadius = widget.borderRadius ?? BorderRadius.circular(4);

    final currentImage = SmoothClipRRect(
      borderRadius: actualBorderRadius,
      child: buildImage(current),
    );

    if (current != null &&
        previous != null &&
        current.hashCode == previous.hashCode) {
      return currentImage;
    }

    final previousImage = SmoothClipRRect(
      borderRadius: actualBorderRadius,
      child: buildImage(previous),
    );

    final animation = SmoothWidgetSwitchAnimation(
      key: ValueKey(current),
      before: previousImage,
      after: currentImage,
      duration: Duration(milliseconds: 500),
    );

    AnimationCombination.newBuilder()
        .add(animation)
        .build(
          onReady: (animation) {
            animation.forwardAll();
          },
        );

    return animation;
  }

  @override
  void initState() {
    super.initState();
    widget._providedNotifier?.addListener(onNotifierChanged);

    if (widget._providedNotifier?.value != null &&
        widget._selfStreamController != null) {
      final bytes = widget._providedNotifier?.value;
      widget._selfStreamController!.add(
        MemoryImage(Uint8List.fromList(bytes!)),
      );
    }
  }

  @override
  void dispose() {
    _previousImageProvider = null;
    _currentImageProvider = null;
    widget._selfStreamController?.close();
    widget._providedNotifier?.removeListener(onNotifierChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inner = StreamBuilder(
      stream: widget.imageProviderStream,
      builder: (context, providerData) {
        _previousImageProvider = _currentImageProvider;
        _currentImageProvider = providerData.data;

        return combine(_currentImageProvider, _previousImageProvider);
      },
    );
    if (widget.enableGestureDetection == true) {
      return MouseRegion(
        onEnter: (_) {
          widget.onHovered?.call();
        },
        onExit: (_) {
          widget.onHoverCancelled?.call();
        },
        child: GestureDetector(
          onTap: () {
            widget.onClicked?.call();
          },
          child: inner,
        ),
      );
    } else {
      return inner;
    }
  }
}
