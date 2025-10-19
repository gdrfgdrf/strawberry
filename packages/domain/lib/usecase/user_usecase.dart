import 'package:dartz/dartz.dart';
import 'package:domain/entity/account_entity.dart';
import 'package:domain/repository/user_habit_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:domain/usecase/strawberry_usecase.dart';
import 'package:pair/pair.dart';

import '../repository/user/user_avatar_repository.dart';
import '../repository/user/user_detail_repository.dart';

abstract class UserUseCase {
  Future<Either<Failure, Profile>> userDetail_type1(
    int userId, {
    bool isLogin = false,
  });

  Future<Either<Failure, Pair<Account, String>>> userDetail_type2({
    bool isLogin = false,
  });

  Future<Either<Failure, void>> avatar(
    int userId,
    String? url,
    bool cache,
    void Function(Either<Failure, ImageItemResult>) receiver,
  );

  Future<Either<Failure, void>> avatarBatch(
    List<ImageBatchItem> items,
    void Function(ImageBatchItemResult)? receiver, {
    bool cache = true,
  });

  Future<Either<Failure, void>> storeHabit(String key, String? value);

  Future<Either<Failure, String?>> habit(String key);
}

class UserUseCaseImpl extends StrawberryUseCase implements UserUseCase {
  final AbstractUserDetailRepository userDetailRepository;
  final AbstractUserAvatarRepository userAvatarRepository;
  final AbstractUserHabitRepository userHabitRepository;

  UserUseCaseImpl(
    this.userDetailRepository,
    this.userAvatarRepository,
    this.userHabitRepository,
  );

  @override
  Future<Either<Failure, Profile>> userDetail_type1(
    int userId, {
    bool isLogin = false,
  }) async {
    serviceLogger!.trace(
      "getting user detail 1, user id: $userId, is login: $isLogin",
    );
    try {
      final result = await userDetailRepository.type1(userId, isLogin: isLogin);
      return Right(result);
    } catch (e, s) {
      serviceLogger!.error(
        "getting user detail 1 error, user id: $userId, is login: $isLogin: $e\n$s",
      );
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, Pair<Account, String>>> userDetail_type2({
    bool isLogin = false,
  }) async {
    serviceLogger!.trace("getting user detail 2, is login: $isLogin");
    try {
      final result = await userDetailRepository.type2(isLogin: isLogin);
      return Right(result);
    } catch (e, s) {
      serviceLogger!.error(
        "getting user detail 2 error, is login: $isLogin: $e\n$s",
      );
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, void>> avatar(
    int userId,
    String? url,
    bool cache,
    void Function(Either<Failure, ImageItemResult>) receiver,
  ) async {
    serviceLogger!.trace(
      "getting user avatar, user id: $userId, cache: $cache",
    );
    try {
      String? actualUrl = url;

      if (actualUrl == null) {
        final profile = await userDetailRepository.type1(
          userId,
          isLogin: false,
        );
        actualUrl = profile.avatarUrl;
      }

      userAvatarRepository.avatar(userId, actualUrl, receiver, cache: false);
      return Right(null);
    } catch (e, s) {
      serviceLogger!.error(
        "getting user avatar error, user id: $userId, cache: $cache: $e\n$s",
      );
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, void>> avatarBatch(
    List<ImageBatchItem> items,
    void Function(ImageBatchItemResult)? receiver, {
    bool cache = true,
  }) async {
    serviceLogger!.trace("getting user avatar batch, cache: $cache");
    try {
      userAvatarRepository.avatarBatch(items, receiver, cache: cache);
      return Right(null);
    } catch (e, s) {
      serviceLogger!.error(
        "getting user avatar batch error, cache: $cache: $e\n$s",
      );
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, void>> storeHabit(String key, String? value) async {
    serviceLogger!.trace("storing user habit, key: $key, value: $value");
    try {
      await userHabitRepository.store(key, value);
      return Right(null);
    } catch (e, s) {
      serviceLogger!.error(
        "storing user habit error, key: $key, value: $value: $e\n$s",
      );
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, String?>> habit(String key) async {
    serviceLogger!.trace("getting user habit, key: $key");
    try {
      return Right(userHabitRepository.habit(key));
    } catch (e, s) {
      serviceLogger!.error("getting user habit error, key: $key: $e\n$s");
      return Left(Failure(e, s));
    }
  }
}
