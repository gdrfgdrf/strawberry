
import 'dart:ui';

import 'package:flutter/cupertino.dart';

class SizeClipper extends CustomClipper<Rect> {
  final double? width;
  final double? height;

  SizeClipper({this.width, this.height});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, width ?? size.width, height ?? size.height);
  }

  @override
  bool shouldReclip(covariant SizeClipper oldClipper) {
    return width != oldClipper.width || height != oldClipper.height;
  }
}