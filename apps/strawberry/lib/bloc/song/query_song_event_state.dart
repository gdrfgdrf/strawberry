
import 'package:dartz/dartz.dart';
import 'package:domain/entity/song_query_entity.dart';
import 'package:domain/result/result.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';

/// {
//   "c": "[{\"id\":407677285,\"v\":0},{\"id\":407677293,\"v\":0}]",
//   "e_r": true,
//   "header": "{\"os\":\"pc\",\"appver\":\"xxx\",\"deviceId\":\"xxx\",\"requestId\":\"xxx\",\"clientSign\":\"xxx\",\"osver\":\"xxx\",\"Nm-GCore-Status\":\"1\"}"
// }
class AttemptQuerySongEvent extends SongEvent {
  final List<int> ids;
  final void Function(Either<Failure, SongQueryEntity>) receiver;

  AttemptQuerySongEvent(this.ids, this.receiver);
}