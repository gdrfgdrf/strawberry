
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class AnErrorWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const AnErrorWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      "packages/resources/assets/error.json",
      animate: true,
      repeat: true,
      width: width,
      height: height,
    );
  }
}
