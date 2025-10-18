import 'package:domain/entity/playlists_entity.dart';
import 'package:domain/navigation_service.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/ui/playlist/desktop/desktop_playlist_page.dart';
import 'package:strawberry/ui/playlist/mobile/mobile_playlist_page.dart';

class HomeRouter extends PageRouter {
  FluroRouter router = FluroRouter();

  RouteDefinition nonePage = RouteDefinition.of("/", (_, _) => SizedBox());
  RouteDefinition playlistPage = RouteDefinition.of(
    "/playlist",
    (context, _) {
      final playlist = context?.settings?.arguments as PlaylistItemEntity;
      if (PlatformExtension.isDesktop) {
        return PlaylistPageDesktop(
          playlist: playlist,
        );
      }
      return PlaylistPageMobile(playlist: playlist);
    }
  );

  // RouteDefinition profile1 = RouteDefinition.of(
  //   "/",
  //   (context, __) => DesktopProfilePage(
  //     userId:
  //         context?.settings?.arguments?.toString() ??
  //         GetIt.instance.get<Profile>().userId.toString(),
  //   ),
  //   transitionDuration: Duration(milliseconds: 500),
  // );
  //
  // RouteDefinition profile2 = RouteDefinition.of(
  //   "/profile",
  //   (context, __) => DesktopProfilePage(
  //     userId:
  //         context?.settings?.arguments?.toString() ??
  //         GetIt.instance.get<Profile>().userId.toString(),
  //   ),
  //   transitionType: TransitionType.fadeIn,
  //   transitionDuration: Duration(milliseconds: 500),
  // );

  @override
  List<RouteDefinition> definitions() {
    return [nonePage, playlistPage];
  }

  @override
  FluroRouter getRouter() {
    return router;
  }
}
