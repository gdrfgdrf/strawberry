import 'package:dartz/dartz.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:strawberry/bloc/album/album_bloc.dart';

class AttemptGetAlbumCoverEvent extends AlbumEvent {
  final String id;
  final String url;
  final bool cache;
  final int? width;
  final int? height;
  final void Function(Either<Failure, ImageItemResult>) receiver;

  AttemptGetAlbumCoverEvent(
    this.id,
    this.url,
    this.receiver, {
    this.cache = true,
    this.width,
    this.height,
  });
}

class AttemptGetAlbumCoverPathEvent extends AlbumEvent {
  final String id;
  final String url;
  final int? width;
  final int? height;
  final void Function(Either<Failure, String>) receiver;

  AttemptGetAlbumCoverPathEvent(
    this.id,
    this.url,
    this.receiver, {
    this.width,
    this.height,
  });
}
