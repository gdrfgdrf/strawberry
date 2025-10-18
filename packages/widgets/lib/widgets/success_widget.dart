
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class SuccessWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const SuccessWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      "packages/resources/assets/success.json",
      animate: true,
      repeat: false,
      width: width,
      height: height,
    );
  }
}
