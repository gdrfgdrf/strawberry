import 'package:dartz/dartz.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:strawberry/bloc/user/user_bloc.dart';

class AttemptGetUserAvatarEvent extends UserEvent {
  final int userId;
  final String? url;
  final bool cache;
  final void Function(Either<Failure, ImageItemResult>) receiver;

  AttemptGetUserAvatarEvent(this.userId, this.receiver, {this.url, this.cache = true});
}

class AttemptGetUserAvatarBatchEvent extends UserEvent {
  final List<ImageBatchItem> items;
  final void Function(ImageBatchItemResult)? receiver;
  final bool cache;

  AttemptGetUserAvatarBatchEvent(
    this.items,
    this.receiver, {
    this.cache = true,
  });
}

class GetUserAvatarBatchAllFutureCreatedEvent extends UserState {


}
