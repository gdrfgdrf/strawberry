import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mutex/mutex.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/play/songbar/desktop_next_song_bar.dart';
import 'package:widgets/animation/animation_bean.dart';
import 'package:widgets/animation/animation_combine.dart';
import 'package:widgets/animation/smooth_fade_animation.dart';

import '../playlist_manager.dart';

class DesktopSongBarController {
  final BuildContext context;
  OverlayEntry? overlayEntry;
  AnimationCombination? animationCombination;

  final Mutex mutex = Mutex();

  DesktopSongBarController(this.context);

  Future<bool> shown() async {
    await mutex.acquire();
    final shown = overlayEntry != null;
    mutex.release();

    return shown;
  }

  void show() async {
    await mutex.acquire();

    if (overlayEntry != null) {
      return;
    }

    GetIt.instance.get<PlaylistManager>();

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

                mutex.release();
              },
            );

        final screenSize = MediaQuery.of(context).size;
        final size = Size(1440.w - 120.w, 64.w + 56.h);
        final i = (screenSize.width - size.width) / 2;

        return Stack(
          children: [
            Positioned(
              width: size.width,
              height: size.height,
              top: screenSize.height - size.height - i,
              left: i,
              child: animation,
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  void hide() async {
    if (overlayEntry == null) {
      return;
    }
    await mutex.acquire();

    if (animationCombination == null) {
      overlayEntry?.remove();
      overlayEntry = null;
      mutex.release();
      return;
    }

    animationCombination?.reverseAllCallback = () {
      overlayEntry?.remove();
      overlayEntry = null;
      animationCombination = null;
      mutex.release();
    };
    animationCombination?.reverseAll();
  }

  static void prepare(BuildContext context) {
    if (!PlatformExtension.isDesktop) {
      return;
    }
    if (!GetIt.instance.isRegistered<DesktopSongBarController>()) {
      final controller = DesktopSongBarController(context);
      GetIt.instance.registerSingleton<DesktopSongBarController>(controller);
    }
  }
}
