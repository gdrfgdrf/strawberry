import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_popup_animation.dart';
import 'package:widgets/floatingtoast/toast_center.dart';

class FloatingCommonToast {
  static Widget buildInner(Widget child) {
    return Opacity(
      opacity: 0.7,
      child: SmoothContainer(
        width: 256.w,
        height: 128.h,
        color: themeData().colorScheme.surfaceContainerLowest,
        padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 4.w),
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: ConstraintLayout(
            children: [
              child.applyConstraint(
                left: parent.left,
                right: parent.right,
                top: parent.top,
                bottom: parent.bottom,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, Widget child) {
    GetIt.instance.get<ToastCenter>().submit(context, buildInner(child));
  }
}
