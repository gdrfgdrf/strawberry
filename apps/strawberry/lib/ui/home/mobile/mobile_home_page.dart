import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared/themes.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:strawberry/app_config.dart';
import 'package:strawberry/play/audio_player_translator.dart';
import 'package:strawberry/play/songbar/desktop_next_song_bar.dart';
import 'package:strawberry/ui/abstract_page.dart';
import 'package:strawberry/ui/home/home_page_delegate.dart';
import 'package:strawberry/ui/router/home_router.dart';
import 'package:we_slide/we_slide.dart';
import 'package:widgets/widgets/scrollable_lyrics.dart';
import 'package:widgets/widgets/smooth_lyrics.dart';

class MobileHomePage extends AbstractUiWidget {
  @override
  State<StatefulWidget> createState() => MobileHomePageState();
}

class MobileHomePageState
    extends AbstractUiWidgetState<MobileHomePage, HomePageDelegate> {
  AudioPlayerTranslator? translator;

  @override
  void initState() {
    super.initState();
    final audioPlayer = GetIt.instance.get<AudioPlayer>();
    translator = AudioPlayerTranslator(audioPlayer);
    translator!.start();
  }

  @override
  HomePageDelegate createDelegate() {
    return HomePageDelegate();
  }

  @override
  void dispose() {
    translator?.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final songBarSize = Size(1440.w - 120.w, 64.w + 56.h);

    return Scaffold(
      appBar: delegate!.getWidget("appbar") as PreferredSizeWidget,
      body: SizedBox.expand(
        child: WeSlide(
          backgroundColor: themeData().scaffoldBackgroundColor,
          footerHeight: 0,
          body: Navigator(
            key: AppConfig.homeNavigatorKey,
            onGenerateRoute:
                GetIt.instance.get<HomeRouter>().getRouter().generator,
          ),
          panel: SmoothContainer(
            width: screenSize.width,
            height: screenSize.height,
            color: themeData().colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            // child: SmoothLyrics(
            //   width: screenSize.width,
            //   height: screenSize.height,
            //   lyricWidth: screenSize.width - 2 * (screenSize.width / 6),
            //   lyricsStream: translator!.lyricsStream(),
            //   positionStream: translator!.audioPlayer.positionStream,
            //   lyricDisplay: LyricDisplay.center,
            // ),
            // child: DesktopPlayingPage(audioPlayer: audioPlayer),
          ),
          panelMinSize: songBarSize.height,
          panelMaxSize: screenSize.height,
          panelHeader: SmoothContainer(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            color: themeData().colorScheme.surfaceContainerLow,
            child: NextSongBarDesktop(audioPlayer: GetIt.instance.get()),
          ),
        ),
      ),
    );
  }
}
