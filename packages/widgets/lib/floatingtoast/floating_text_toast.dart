import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widgets/floatingtoast/floating_common_toast.dart';

class FloatingTextToast {
  static void show(BuildContext context, String text) {
    FloatingCommonToast.show(
      context,
      Text(text, style: TextStyle(fontSize: 24.sp)),
    );
  }
}
