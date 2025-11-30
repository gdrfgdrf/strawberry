import 'package:flutter/material.dart';

enum CharStatus { down, up }

class CharData {
  final String char;
  CharStatus status;
  Duration? duration;

  CharData(this.char, this.status, {this.duration});
}

class CharUpdate {
  final int index;
  final CharStatus status;
  final Duration duration;

  const CharUpdate(this.index, this.status, this.duration);
}

class AnimatedCharText extends StatefulWidget {
  final int lyricIndex;
  final List<CharData> chars;

  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? softWrap;

  final Curve curve;

  final double downOpacity;
  final double upOpacity;

  final double offset;

  final bool traceability;

  final Axis wrapDirection;
  final WrapAlignment wrapAlignment;
  final double wrapSpacing;
  final WrapAlignment wrapRunAlignment;
  final double wrapRunSpacing;
  final WrapCrossAlignment wrapCrossAlignment;
  final TextDirection? wrapTextDirection;
  final VerticalDirection wrapVerticalDirection;
  final Clip wrapClipBehavior;

  const AnimatedCharText({
    super.key,
    required this.lyricIndex,
    required this.chars,
    this.textAlign,
    this.softWrap,
    this.style,
    this.curve = Curves.fastEaseInToSlowEaseOut,
    this.downOpacity = 0.4,
    this.upOpacity = 1.0,
    this.offset = -6,
    this.traceability = true,
    this.wrapDirection = Axis.horizontal,
    this.wrapAlignment = WrapAlignment.start,
    this.wrapSpacing = 0.0,
    this.wrapRunAlignment = WrapAlignment.start,
    this.wrapRunSpacing = 0.0,
    this.wrapCrossAlignment = WrapCrossAlignment.start,
    this.wrapTextDirection,
    this.wrapVerticalDirection = VerticalDirection.down,
    this.wrapClipBehavior = Clip.none,
  });

  @override
  State<AnimatedCharText> createState() => _AnimatedCharTextState();
}

class _AnimatedCharTextState extends State<AnimatedCharText> {
  @override
  Widget build(BuildContext context) {
    if (widget.chars.isEmpty == true) {
      return SizedBox.shrink();
    }
    return Wrap(
      direction: widget.wrapDirection,
      alignment: widget.wrapAlignment,
      spacing: widget.wrapSpacing,
      runAlignment: widget.wrapRunAlignment,
      runSpacing: widget.wrapRunSpacing,
      crossAxisAlignment: widget.wrapCrossAlignment,
      textDirection: widget.wrapTextDirection,
      verticalDirection: widget.wrapVerticalDirection,
      clipBehavior: widget.wrapClipBehavior,
      children: List.generate(widget.chars.length, (index) {
        final charData = widget.chars[index];

        return AnimatedChar(
          lyricIndex: widget.lyricIndex,
          char: charData.char,
          status: charData.status,
          style: widget.style,
          textAlign: widget.textAlign,
          softWrap: widget.softWrap,
          duration: charData.duration ?? Duration(milliseconds: 500),
          downOpacity: widget.downOpacity,
          upOpacity: widget.upOpacity,
          offset: widget.offset,
        );
      }),
    );
  }
}

class AnimatedChar extends StatefulWidget {
  final int lyricIndex;
  final CharStatus status;

  final String char;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? softWrap;

  final double downOpacity;
  final double upOpacity;
  final double offset;

  final Duration duration;

  const AnimatedChar({
    super.key,
    required this.lyricIndex,
    required this.status,
    required this.char,
    this.style,
    this.textAlign,
    this.softWrap,
    this.downOpacity = 0.4,
    this.upOpacity = 1.0,
    this.offset = -6,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedChar> createState() => _AnimatedCharState();
}

class _AnimatedCharState extends State<AnimatedChar>
    with TickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    animation = Tween(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );
    animationController?.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedChar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.status != widget.status) {
      setState(() {
        animation = Tween(
          begin: oldWidget.status == CharStatus.up ? 1.0 : 0.0,
          end: oldWidget.status == CharStatus.up ? 0.0 : 1.0,
        ).animate(
          CurvedAnimation(
            parent: animationController!,
            curve: Curves.fastEaseInToSlowEaseOut,
          ),
        );

        animationController?.duration = widget.duration;
        animationController?.reset();
        animationController?.forward();
      });
    }
  }

  @override
  void dispose() {
    animation = null;
    animationController?.dispose();
    animationController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation!,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, animation!.value * widget.offset),
          child: AnimatedOpacity(
            opacity: _getOpacity(),
            duration: widget.duration,
            child: Text(
              widget.char,
              textAlign: widget.textAlign,
              softWrap: widget.softWrap,
              style: widget.style ?? TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  double _getOpacity() {
    switch (widget.status) {
      case CharStatus.down:
        return widget.downOpacity;
      case CharStatus.up:
        return widget.upOpacity;
    }
  }
}
