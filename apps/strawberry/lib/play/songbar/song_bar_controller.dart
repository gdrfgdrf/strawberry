import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/play/songbar/desktop_next_song_bar.dart';
import 'package:widgets/animation/animation_bean.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_fade_animation.dart';

abstract class SongBarController {
  void show(BuildContext context, {double coefficient = 1});

  void hide();

  static SongBarController getOrCreate() {
    if (GetIt.instance.isRegistered<SongBarController>()) {
      return GetIt.instance.get<SongBarController>();
    }
    final controller = _DesktopSongBarController();
    GetIt.instance.registerSingleton<SongBarController>(controller);
    return controller;
  }
}

abstract class _CommonSongBarController extends SongBarController {
  OverlayEntry? overlayEntry;
  AnimationCombination? animationCombination;

  Widget build(BuildContext context);

  Size getSize(BuildContext context);

  @override
  void show(BuildContext context, {double coefficient = 1}) {
    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        final animation = SmoothFadeInAnimation(
          duration: Duration(milliseconds: 500),
          direction: AnimationDirection.verticalBottomToTop,
          child: build(context),
        );

        AnimationCombination.newBuilder()
            .add(animation)
            .build(
              onReady: (animation) {
                animationCombination = animation;
                animation.forwardAll();
              },
            );

        final screenSize = MediaQuery.of(context).size;
        final size = getSize(context);
        final i = (screenSize.width - size.width) / 2;

        return Stack(
          children: [
            Positioned(
              width: size.width,
              height: size.height,
              top: screenSize.height - size.height - coefficient * i,
              left: i,
              child: animation,
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  @override
  void hide() {
    if (overlayEntry == null) {
      return;
    }
    if (animationCombination == null) {
      overlayEntry?.remove();
      overlayEntry = null;
      return;
    }

    animationCombination?.reverseAllCallback = () {
      overlayEntry?.remove();
      overlayEntry = null;
      animationCombination = null;
    };
    animationCombination?.reverseAll();
  }
}

class _DesktopSongBarController extends _CommonSongBarController {
  @override
  void show(BuildContext context, {double coefficient = 1}) {
    if (!PlatformExtension.isDesktop) {
      return;
    }

    super.show(context, coefficient: coefficient);
  }

  @override
  void hide() {
    if (!PlatformExtension.isDesktop) {
      return;
    }
    super.hide();
  }

  @override
  Widget build(BuildContext context) {
    return NextSongBarDesktop(audioPlayer: GetIt.instance.get<AudioPlayer>());
  }

  @override
  Size getSize(BuildContext context) {
    return Size(1440.w - 120.w, 64.w + 56.h);
  }
}