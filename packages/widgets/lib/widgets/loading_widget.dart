
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const LoadingWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      "packages/resources/assets/loading.json",
      animate: true,
      repeat: true,
      width: width,
      height: height,
    );
  }
}
