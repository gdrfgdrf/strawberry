import 'package:dartz/dartz.dart';
import 'package:data/cache/cache_system.dart';
import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/task_chain.dart';
import 'package:domain/repository/image_repository.dart';
import 'package:domain/result/result.dart';
import 'package:domain/usecase/image_usecase.dart';
import 'package:get_it/get_it.dart';

class ImageRepositoryImpl extends AbstractImageRepository {
  void fromCache(
    String url,
    CacheChannel channel,
    String cacheTag,
    void Function(Either<Failure, ImageItemResult>) receiver,
    int? width,
    int? height,
  ) async {
    final cacheSystem = await GetIt.instance.getAsync<CacheSystem>();
    final cacheManager = cacheSystem.manager(channel);

    final parsedUrl = Uri.parse(url);
    String path = parsedUrl.path;
    if (width != null && height != null) {
      path = "$path?param=${width}x$height";
    }

    final shouldUpdate = await cacheManager.shouldUpdate(cacheTag, path);
    if (shouldUpdate) {
      fromNetwork(url, channel, cacheTag, receiver, width, height);
      return;
    }

    cacheManager
        .fetch(cacheTag)
        .then((bytes) {
          final result = ImageItemResult(url, cacheTag, channel, bytes);
          receiver(Right(result));
        })
        .onError((e, s) {
          fromNetwork(url, channel, cacheTag, receiver, width, height);
        });
  }

  void fromNetwork(
    String url,
    CacheChannel channel,
    String cacheTag,
    void Function(Either<Failure, ImageItemResult>) receiver,
    int? width,
    int? height,
  ) {
    final parsedUrl = Uri.parse(url);
    String path = parsedUrl.path;
    if (width != null && height != null) {
      path = "$path?param=${width}x$height";
    }

    final endpoint = Endpoint(
      path: path,
      method: HttpMethod.get,
      baseUrl: "${parsedUrl.scheme}://${parsedUrl.host}",
    );

    final taskStream = TaskChain();

    taskStream
        .imageNetwork(() => endpoint)
        .onComplete((compressed, _) async {
          final cacheSystem = await GetIt.instance.getAsync<CacheSystem>();
          final cacheManager = cacheSystem.manager(channel);
          /// 不加后缀 Windows 的 SMTC 读取不了
          cacheManager.cache(cacheTag, path, compressed, extension: "jpg");

          final result = ImageItemResult(url, cacheTag, channel, compressed);

          receiver(Right(result));
        })
        .globalOnError((_, e, s) {
          receiver(Left(Failure(e, s)));
        })
        .run();
  }

  @override
  void fetch(
    ImageItem imageItem,
    void Function(Either<Failure, ImageItemResult>) receiver, {
    bool cache = true,
    int? width,
    int? height,
  }) {
    if (cache) {
      fromCache(
        imageItem.url,
        imageItem.channel,
        imageItem.cacheTag,
        receiver,
        width,
        height,
      );
      return;
    }

    fromNetwork(
      imageItem.url,
      imageItem.channel,
      imageItem.cacheTag,
      receiver,
      width,
      height,
    );
  }

  @override
  void path(
    ImageItem imageItem,
    void Function(Either<Failure, String>) receiver, {
    int? width,
    int? height,
  }) {
    fetch(
      imageItem,
      (data) async {
        data.fold((failure) {
          receiver(Left(failure));
        }, (_) {});
        if (data.isLeft()) {
          return;
        }

        final channel = imageItem.channel;
        final cacheSystem = await GetIt.instance.getAsync<CacheSystem>();
        final cacheManager = cacheSystem.manager(channel);

        final path = await cacheManager.path(imageItem.cacheTag);
        receiver(Right(path));
      },
      width: width,
      height: height,
    );
  }
}
