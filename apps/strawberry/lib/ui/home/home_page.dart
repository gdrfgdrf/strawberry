import 'package:domain/entity/account_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/platform_extension.dart';
import 'package:strawberry/bloc/playlist/get_playlists_event_state.dart';
import 'package:strawberry/bloc/playlist/playlist_bloc.dart';
import 'package:strawberry/bloc/playlist/query_playlist_event_state.dart';
import 'package:strawberry/ui/home/desktop/desktop_home_page.dart';
import 'package:strawberry/ui/home/mobile/mobile_home_page.dart';
import 'package:domain/loved_playlist_ids_holder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PlaylistBloc playlistBloc = GetIt.instance.get();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idsHolder = LovedPlaylistIdsHolder();
      GetIt.instance.registerSingleton(idsHolder);

      final profile = GetIt.instance.get<Profile>();
      playlistBloc.add(
        AttemptGetPlaylistsEvent(profile.userId, PlaylistSource.userCreated),
      );
    });
  }

  @override
  void dispose() {
    playlistBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      listener: (context, state) {
        if (state is GetPlaylistsSuccess) {
          final lovedPlaylist = state.playlists.findLovedPlaylist();
          if (lovedPlaylist == null) {
            return;
          }
          final id = lovedPlaylist.id;
          playlistBloc.add(AttemptQueryBasicPlaylistEvent(id));
        }
        if (state is QueryBasicPlaylistSuccess) {
          final songIds = state.playlistQuery.songIds;
          final ids = <int>[];
          for (final songId in songIds) {
            ids.add(songId.id);
          }
          GetIt.instance.get<LovedPlaylistIdsHolder>().update(ids);
        }
      },
      bloc: playlistBloc,
      child: PlatformExtension.isMobile ? MobileHomePage() : DesktopHomePage(),
    );
  }
}
