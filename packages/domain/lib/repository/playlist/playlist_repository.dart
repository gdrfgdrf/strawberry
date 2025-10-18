
import 'package:domain/entity/playlist_query_entity.dart';

abstract class AbstractPlaylistRepository {
  Future<PlaylistQueryEntity> query(int id, int songCount);
}