import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/play/songbar/desktop_next_song_bar.dart';
import 'package:widgets/animation/animation_bean.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_fade_animation.dart';

import '../playlist_manager.dart';

class DesktopSongBarController {
  OverlayEntry? overlayEntry;
  AnimationCombination? animationCombination;

  void show(BuildContext context) {
    GetIt.instance.get<PlaylistManager>();

    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        final animation = SmoothFadeInAnimation(
          duration: Duration(milliseconds: 500),
          direction: AnimationDirection.verticalBottomToTop,
          child: NextSongBarDesktop(
            audioPlayer: GetIt.instance.get<AudioPlayer>(),
          ),
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
        final i = (screenSize.width - 1440.w - 120.w) / 2;

        return Stack(
          children: [
            Positioned(
              width: 1440.w - 120.w,
              height: 64.w + 56.h,
              top: screenSize.height - 64.w + 56.h - i,
              left: i,
              child: animation,
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(overlayEntry!);
  }

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

  static void prepare() {
    if (!PlatformExtension.isDesktop) {
      return;
    }
    final controller = DesktopSongBarController();
    GetIt.instance.registerSingleton<DesktopSongBarController>(controller);
  }
}
