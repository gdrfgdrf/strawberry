import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';

class StrawberryIcon extends StatefulWidget {
  final double _width;
  final double _height;
  final double _elevation;
  final Color? _cardColor;
  final Color? _svgColor;

  const StrawberryIcon(
    double width,
    double height, {
    super.key,
    double? elevation,
    Color? cardColor,
    Color? svgColor,
  }) : _width = width,
       _height = height,
       _elevation = elevation ?? 8,
       _cardColor = cardColor,
       _svgColor = svgColor;

  static StrawberryIcon square(double size) {
    return StrawberryIcon(size, size);
  }

  static StrawberryIcon window(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final squareSize = size.width > size.height ? size.height : size.width;

    return StrawberryIcon.square(squareSize > 100 ? 100 : squareSize / 2);
  }

  @override
  State<StatefulWidget> createState() => _StrawberryIconState();
}

class _StrawberryIconState extends State<StrawberryIcon> {
  @override
  Widget build(BuildContext context) {
    String path = "packages/resources/assets/strawberry.svg";

    return SizedBox(
      width: widget._width,
      height: widget._height,
      child: SmoothCard(
        elevation: widget._elevation,
        borderRadius: BorderRadius.circular(16),
        color: widget._cardColor ?? themeData().colorScheme.surfaceContainerHigh,
        child: SvgPicture.asset(
          path,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            widget._svgColor ?? themeData().colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
