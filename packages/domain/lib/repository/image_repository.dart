import 'package:dartz/dartz.dart';

import '../result/result.dart';
import '../usecase/image_usecase.dart';

abstract class AbstractImageRepository {
  void fetch(
    ImageItem imageItem,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
    int? width,
    int? height,
  });

  void path(
    ImageItem imageItem,
    void Function(Either<Failure, String>) receiver, {
    int? width,
    int? height,
  });
}
