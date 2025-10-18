
import 'package:get_it/get_it.dart';
import 'package:strawberry/bloc/playlist/playlist_bloc.dart';
import 'package:strawberry/ui/abstract_delegate.dart';

class PlaylistsGridDelegate extends AbstractDelegate {
  final PlaylistBloc playlistBloc = GetIt.instance.get();

  PlaylistsGridDelegate() {
    registerBloc(playlistBloc);
  }

}