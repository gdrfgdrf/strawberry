import 'package:dartz/dartz.dart';
import 'package:domain/entity/account_entity.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/combination/combination_factory.dart';
import 'package:shared/combination/combined.dart';
import 'package:strawberry/bloc/playlist/playlist_bloc.dart';
import 'package:strawberry/bloc/user/get_user_avatar_event_state.dart';
import 'package:strawberry/bloc/user/user_bloc.dart';
import 'package:strawberry/ui/abstract_delegate.dart';

import '../../bloc/user/get_user_detail_event_state.dart';

class ProfilePageDelegate extends AbstractDelegate {
  UserBloc userBloc = GetIt.instance.get();

  ValueNotifier<List<int>?> avatarNotifier = ValueNotifier(null);
  ValueNotifier<Profile?> profileNotifier = ValueNotifier(null);
  ValueNotifier<PlaylistSource> playlistSourceNotifier = ValueNotifier(PlaylistSource.userCreated);

  Profile? profile;

  ProfilePageDelegate() {
    registerBloc(userBloc);
  }

  void tryGetUserDetail(int userId) {
    userBloc.add(AttemptGetUserDetailEvent_Type1(userId));
  }

  void tryFetchAvatar() {
    final profile = profileNotifier.value;
    if (profile == null) {
      throw ArgumentError("profile is not fetched");
    }

    userBloc.add(AttemptGetUserAvatarEvent(profile.userId, avatarReceiver));
  }

  void avatarReceiver(Either<Failure, ImageItemResult> data) {
    data.fold(
      (failure) {
        serviceLogger!.error(
          "fetch avatar error: $hashCode: ${failure.error}\n${failure.stackTrace}",
        );
      },
      (result) {
        avatarNotifier.value = result.bytes;
      },
    );
  }

  @override
  void dispose() {
    avatarNotifier.dispose();
    profileNotifier.dispose();
    playlistSourceNotifier.dispose();
    super.dispose();
  }
}
