import 'package:dartz/dartz.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:strawberry/bloc/playlist/playlist_bloc.dart';

class AttemptGetPlaylistCoverEvent extends PlaylistEvent {
  final int id;
  final String url;
  final bool cache;
  final void Function(Either<Failure, ImageItemResult>) receiver;

  AttemptGetPlaylistCoverEvent(
    this.id,
    this.url,
    this.receiver, {
    this.cache = true,
  });
}

class AttemptGetPlaylistCoverBatchEvent extends PlaylistEvent {
  final List<ImageBatchItem> items;
  final bool cache;

  final void Function(ImageBatchItemResult)? receiver;

  AttemptGetPlaylistCoverBatchEvent(
    this.items,
    this.receiver, {
    this.cache = true,
  });
}
