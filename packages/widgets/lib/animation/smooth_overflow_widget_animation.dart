import 'package:flutter/cupertino.dart';

class MutationCurve extends Curve {
  final List<double> values;
  final int segmentCount;

  const MutationCurve(this.values) : segmentCount = values.length;

  @override
  double transform(double t) {
    if (values.isEmpty) {
      return 0.0;
    }
    if (values.length == 1) {
      return values[0];
    }

    double position = t * segmentCount;

    int index = position.floor();

    if (index < 0) {
      return values.first;
    }
    if (index >= segmentCount) {
      return values.last;
    }

    return values[index];
  }
}

class ChunkInfo {
  final Animation<double> animation;
  final AnimationController controller;

  const ChunkInfo(this.animation, this.controller);
}

class SmoothOverflowWidgetAnimation extends StatefulWidget {
  final Widget child;
  final GlobalKey parentKey;
  final GlobalKey childKey;

  final double chunkSize;
  final Axis axis;
  final Duration eachDuration;
  double? axisSize;

  SmoothOverflowWidgetAnimation({
    super.key,
    required this.child,
    required this.parentKey,
    required this.childKey,
    required this.chunkSize,
    required this.axis,
    required this.eachDuration,
    this.axisSize,
  });

  @override
  State<StatefulWidget> createState() => _SmoothOverflowWidgetAnimationState();
}

class _SmoothOverflowWidgetAnimationState
    extends State<SmoothOverflowWidgetAnimation>
    with TickerProviderStateMixin {
  bool prepared = false;

  double mainAxisSize = 0;
  List<double> offsets = [];
  List<ChunkInfo> chunks = [];

  AnimationController? mainController;
  Animation<double>? mainAnimation;

  double totalOffset = 0;

  @override
  void initState() {
    super.initState();
    mainController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      prepare();
    });
  }

  @override
  void dispose() {
    mainController?.dispose();
    for (final chunk in chunks) {
      chunk.controller.dispose();
    }
    super.dispose();
  }

  void prepare() {
    final childRenderBox =
        widget.childKey.currentContext?.findRenderObject() as RenderBox?;
    final renderBox =
        widget.parentKey.currentContext?.findRenderObject() as RenderBox?;
    if (childRenderBox == null || renderBox == null) {
      return;
    }
    if (prepared) {
      return;
    }
    prepared = true;

    if (widget.axis == Axis.horizontal) {
      final parentWidth = renderBox.size.width;
      final childWidth = childRenderBox.size.width;
      if (childWidth <= parentWidth) {
        return;
      }
    } else {
      final parentHeight = renderBox.size.height;
      final childHeight = childRenderBox.size.height;
      if (childHeight <= parentHeight) {
        return;
      }
    }

    mainAxisSize =
        widget.axis == Axis.horizontal
            ? childRenderBox.size.width
            : childRenderBox.size.height;

    double currentOffset = 0;
    while (currentOffset + widget.chunkSize <= mainAxisSize) {
      currentOffset += widget.chunkSize;
      offsets.add(currentOffset);
    }

    final totalDuration = Duration(
      milliseconds: offsets.length * widget.eachDuration.inMilliseconds,
    );
    mainController!.duration = totalDuration;

    chunks = List.generate(offsets.length, (index) {
      final begin = index * widget.chunkSize;
      final end = (index + 1) * widget.chunkSize;
      final singleController = AnimationController(
        vsync: this,
        duration: widget.eachDuration,
      );

      final animation = Tween(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: singleController,
          curve: Curves.fastEaseInToSlowEaseOut,
        ),
      );

      return ChunkInfo(animation, singleController);
    });

    final backController = AnimationController(
      vsync: this,
      duration: widget.eachDuration,
    );
    final backAnimation = CurvedAnimation(
      parent: backController,
      curve: Interval(0.0, 1.0, curve: Curves.fastEaseInToSlowEaseOut),
    );
    final backChunk = ChunkInfo(backAnimation, backController);
    chunks.add(backChunk);

    mainAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainController!,
        curve: MutationCurve(
          List.generate(chunks.length, (index) => index.toDouble()),
        ),
      ),
    );

    mainController!.reset();
    mainController!.repeat();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (mainAnimation == null) {
      return widget.child;
    }
    if (offsets.isEmpty) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: mainAnimation!,
      builder: (_, __) {
        final index = mainAnimation!.value.toInt();
        final chunkInfo = chunks[index];
        final singleController = chunkInfo.controller;
        final animation = chunkInfo.animation;
        singleController.forward().then((_) {
          singleController.reset();
        });

        return AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            if (mainAnimation!.value.toInt() >= chunks.length - 1.0) {
              totalOffset = totalOffset * (1 - animation.value);
            } else {
              final value = animation.value;
              totalOffset = value;
            }

            return Transform.translate(
              offset:
                  widget.axis == Axis.horizontal
                      ? Offset(-totalOffset, 0)
                      : Offset(0, -totalOffset),
              child: widget.child,
            );
          },
        );
      },
    );
  }
}
