import 'package:dartz/dartz.dart';

import '../result/result.dart';
import '../usecase/image_usecase.dart';

abstract class AbstractAlbumRepository {
  void cover(
    String id,
    String url,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
    int? width,
    int? height,
  });

  void coverPath(
    String id,
    String url,
    void Function(Either<Failure, String>) receiver, {
    int? width,
    int? height,
  });
}
