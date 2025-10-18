
import 'package:domain/entity/playlists_entity.dart';
import 'package:domain/navigation_service.dart';

class HomeNavigatorImpl extends AbstractHomeNavigator {
  HomeNavigatorImpl(super.navigatorStateKey, super.router);

  @override
  void navigatePlaylist(PlaylistItemEntity playlist) {
    navigateTo("/playlist", argument: playlist);
  }
}