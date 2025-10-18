
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class FailWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const FailWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      "packages/resources/assets/fail.json",
      animate: true,
      repeat: false,
      width: width,
      height: height,
    );
  }
}
