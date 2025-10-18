import 'package:dartz/dartz.dart';
import 'package:domain/usecase/image_usecase.dart';

import '../../result/result.dart';

abstract class AbstractUserAvatarRepository {
  void avatar(
    int id,
    String url,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
  });

  void avatarBatch(
    List<ImageBatchItem> items,
    void Function(ImageBatchItemResult)? receiver, {
    bool cache = true,
  });
}
