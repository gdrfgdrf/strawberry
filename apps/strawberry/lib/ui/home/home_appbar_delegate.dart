import 'package:dartz/dartz.dart';
import 'package:domain/entity/account_entity.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:strawberry/bloc/user/get_user_avatar_event_state.dart';
import 'package:strawberry/bloc/user/user_bloc.dart';
import 'package:strawberry/ui/abstract_secondary_delegate.dart';
import 'package:widgets/widgets/smooth_image.dart';

class HomeAppBarDelegate extends AbstractSecondaryDelegate {
  final avatarKey = GlobalKey<SmoothImageState>();
  ValueNotifier<List<int>?> avatarNotifier = ValueNotifier(null);

  UserBloc userBloc = GetIt.instance.get();

  HomeAppBarDelegate() {
    registerBloc(userBloc);
  }

  void tryFetchAvatar() {
    serviceLogger!.trace("trying to fetch avatar: $hashCode");

    final profile = GetIt.instance.get<Profile>();
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
        serviceLogger!.trace("avatar received: $hashCode");
        avatarNotifier.value = result.bytes;
      },
    );
  }

  @override
  void dispose() {
    avatarNotifier.dispose();
    super.dispose();
  }
}
