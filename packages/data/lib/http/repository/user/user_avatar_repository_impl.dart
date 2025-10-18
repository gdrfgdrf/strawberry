import 'package:dartz/dartz.dart';
import 'package:domain/repository/image_repository.dart';
import 'package:domain/repository/user/user_avatar_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:get_it/get_it.dart';

import '../../../cache/cache_system.dart';

class UserAvatarRepositoryImpl extends AbstractUserAvatarRepository {
  @override
  void avatar(
    int id,
    String url,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
  }) {
    final imageRepository = GetIt.instance.get<AbstractImageRepository>();
    final imageItem = ImageItem(url, id.toString(), CacheChannel.avatars);

    imageRepository.fetch(imageItem, receiver);
  }

  @override
  void avatarBatch(
    List<ImageBatchItem> items,
    void Function(ImageBatchItemResult)? receiver, {
    bool cache = true,
  }) {
    for (final item in items) {
      final id = item.cacheTag;
      final url = item.url;

      avatar(int.parse(id), url, (data) {
        data.fold(
          (failure) {
            final result = ImageBatchItemResult(url, id, null);
            receiver?.call(result);
          },
          (result) {
            final batchResult = ImageBatchItemResult(url, id, result.bytes);
            receiver?.call(batchResult);
          },
        );
      }, cache: cache);
    }
  }
}
