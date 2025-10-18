import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:domain/repository/image_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/strawberry_usecase.dart';

class ImageItem {
  final String url;
  final String cacheTag;
  final dynamic channel;

  const ImageItem(this.url, this.cacheTag, this.channel);
}

class ImageItemResult {
  final String url;
  final String cacheTag;
  final dynamic channel;
  final List<int> bytes;

  const ImageItemResult(this.url, this.cacheTag, this.channel, this.bytes);
}

class ImageBatchItem {
  final String url;
  final String cacheTag;

  const ImageBatchItem(this.url, this.cacheTag);
}

class ImageBatchItemResult {
  final String url;
  final String cacheTag;
  final List<int>? result;

  const ImageBatchItemResult(this.url, this.cacheTag, this.result);
}

abstract class ImageUseCase {
  Future<Either<Failure, void>> fetch(
    ImageItem imageItem,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
  });

  Future<Either<Failure, void>> fetchBatch(
    List<ImageBatchItem> items,
    dynamic channel, {
    bool cache = true,
    void Function(ImageBatchItemResult)? receiver,
  });
}

class ImageUseCaseImpl extends StrawberryUseCase implements ImageUseCase {
  final AbstractImageRepository imageRepository;

  ImageUseCaseImpl(this.imageRepository);

  @override
  Future<Either<Failure, void>> fetch(
    ImageItem imageItem,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
  }) async {
    final url = imageItem.url;
    final channel = imageItem.channel;
    final cacheTag = imageItem.cacheTag;

    serviceLogger!.trace(
      "fetching image, url: $url, channel: $channel, cache tag: $cacheTag, cache: $cache",
    );
    try {
      imageRepository.fetch(imageItem, receiver, cache: cache);
      return Right(null);
    } catch (e, s) {
      serviceLogger!.error(
        "fetching image error, url: $url, channel: $channel, cache tag: $cacheTag, cache: $cache: $e\n$s",
      );
      return Left(Failure(e, s));
    }
  }

  @override
  Future<Either<Failure, void>> fetchBatch(
    List<ImageBatchItem> items,
    channel, {
    bool cache = true,
    void Function(ImageBatchItemResult)? receiver,
  }) async {
    for (final item in items) {
      final String url = item.url;
      final String cacheTag = item.cacheTag;
      final imageItem = ImageItem(url, cacheTag, channel);

      fetch(imageItem, (data) {
        data.fold(
          (failure) {
            serviceLogger!.error(
              "image fetch error, url: $url, channel: $channel, cache tag: $cacheTag, cache: $cache: ${failure.error}\n${failure.stackTrace}",
            );
            receiver?.call(ImageBatchItemResult(url, cacheTag, null));
          },
          (result) {
            serviceLogger!.trace(
              "image received, url: $url, channel: $channel, cache tag: $cacheTag, cache: $cache",
            );
            final batchResult = ImageBatchItemResult(
              url,
              cacheTag,
              result.bytes,
            );
            receiver?.call(batchResult);
          },
        );
      });
    }

    return Right(null);
  }
}
