
import 'package:dartz/dartz.dart';
import 'package:domain/entity/song_entity.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoverRequest {
  final String id;
  final String url;
  ValueNotifier<List<int>?>? notifier = ValueNotifier(null);

  bool? requesting = false;
  bool? requested = false;

  CoverRequest(this.id, this.url);

  bool shouldRequest() {
    if (requesting == true) {
      return false;
    }
    if (requested == true) {
      return false;
    }
    requesting = true;
    return true;
  }

  void coverReceiver(Either<Failure, ImageItemResult> data) {
    data.fold((failure) {
      error();
    }, (result) {
      success(result.bytes);
    });
  }

  void success(List<int> bytes) {
    requesting = false;
    requested = true;
    try {
      notifier?.value = bytes;
    } catch (e) {
      /// ignored
    }
  }

  void error() {
    requesting = false;
    requested = false;
  }

  void dispose() {
    notifier?.dispose();
    notifier = null;
    requesting = null;
    requested = null;
  }

  static CoverRequest? fromSong(SongEntity song) {
    final album = song.basicAlbum;

    final url = album?.picUrl;
    if (url == null) {
      return null;
    }
    return CoverRequest(song.compatibleAlbumId(), url);
  }
}