import 'package:domain/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/platform_extension.dart';
import 'package:widgets/animation/animation_bean.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_scale_animation.dart';
import 'package:widgets/widgets/strawberry_icon.dart';
import 'package:window_manager/window_manager.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    // if (PlatformExtension.isDesktop) {
    //   WindowManager.instance.setResizable(false);
    //   WindowManager.instance.setSize(Size(306, 486));
    //   WindowManager.instance.setMinimumSize(Size(306, 486));
    //   WindowManager.instance.setMaximumSize(Size(306, 486));
    // }

    final icon = StrawberryIcon.window(context);

    final iconScaleAnimation = SmoothScaleAnimation(
      duration: Duration(milliseconds: 500),
      ratio: ScaleRatio(0.0, 1.0),
      child: icon,
    );

    AnimationCombinationBuilder()
        .add(iconScaleAnimation)
        .build(
          onReady: (combination) {
            combination.chained().forward().ready().whenComplete(() {
              final navigator = GetIt.instance.get<AbstractMainNavigator>();
              navigator.navigateLogin();
            });
          },
        );

    return Scaffold(
      body: Center(
        child: Hero(tag: "strawberry_icon", child: iconScaleAnimation),
      ),
    );
  }
}
