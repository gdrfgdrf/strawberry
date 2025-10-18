import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class NoDataWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const NoDataWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      "packages/resources/assets/no_data.json",
      animate: true,
      repeat: true,
      width: width,
      height: height,
    );
  }
}
