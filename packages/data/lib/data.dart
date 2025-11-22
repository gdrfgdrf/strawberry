import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:data/cache/cache_system.dart';
import 'package:data/center/cookie_center.dart';
import 'package:data/center/song_combination.dart';
import 'package:data/hive/hive_registrar.g.dart';
import 'package:data/http/repository/album_repository_impl.dart';
import 'package:data/http/repository/auth_repository_impl.dart';
import 'package:data/http/repository/image_repository_impl.dart';
import 'package:data/http/repository/playlist/playlist_repository_impl.dart';
import 'package:data/http/repository/qr_code_repository_impl.dart';
import 'package:data/http/repository/search_repository_impl.dart';
import 'package:data/http/repository/song_repository_impl.dart';
import 'package:data/http/repository/user_habit_repository_impl.dart';
import 'package:data/http/url/api_url_provider.dart';
import 'package:data/http/url/api_url_provider_impl.dart';
import 'package:data/isolatepool/isolate_pool_manager.dart';
import 'package:domain/entity/login_result.dart';
import 'package:domain/entity/song_file_entity.dart';
import 'package:domain/entity/store_lyrics_entity.dart';
import 'package:domain/entity/user_habit_entity.dart';
import 'package:domain/hives.dart';
import 'package:domain/repository/album_repository.dart';
import 'package:domain/repository/auth_repository.dart';
import 'package:domain/repository/image_repository.dart';
import 'package:domain/repository/playlist/playlist_repository.dart';
import 'package:domain/repository/playlist/playlists_repository.dart';
import 'package:domain/repository/qr_code_repository.dart';
import 'package:domain/repository/search_repository.dart';
import 'package:domain/repository/song_repository.dart';
import 'package:domain/repository/user/user_avatar_repository.dart';
import 'package:domain/repository/user/user_detail_repository.dart';
import 'package:domain/repository/user_habit_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:path_provider/path_provider.dart';

import 'http/repository/playlist/playlists_repository_impl.dart';
import 'http/repository/user/user_avatar_repository_impl.dart';
import 'http/repository/user/user_detail_repository_impl.dart';

class DataModule {
  static Directory? cachedDocumentsDirectory;

  static configure() async {
    final getIt = GetIt.instance;
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring data module");

    logger.trace("configuring url provider singleton");
    GetIt.instance.registerLazySingleton<UrlProvider>(() => UrlProviderImpl());

    cachedDocumentsDirectory = await getApplicationDocumentsDirectory();

    _configureCache(getIt);
    _configureCookies(getIt);
    _configureRepositories(getIt);
  }

  static configureCookieCenter() async {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring cookie center");

    await CookieCenter.initialize();
  }

  static configureIsolatePool() async {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring isolate pool");

    final isolatePool = IsolatePool();
    await isolatePool.initializeIsolates();
    GetIt.instance.registerSingleton(isolatePool);
  }

  static configureHive() async {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring hive ce storage");

    await Hive.initFlutter();
    Hive.registerAdapters();

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}${Platform.pathSeparator}strawberry_data";

    await Hive.openBox<SongCombination>(HiveBoxes.songCombination, path: path);
    await Hive.openBox<LoginResult>(HiveBoxes.loginResult, path: path);
    await Hive.openBox<UserHabit>(HiveBoxes.userHabit, path: path);
    await Hive.openBox<SongFileEntity>(HiveBoxes.songFile, path: path);
    await Hive.openBox<StoreLyrics>(HiveBoxes.lyrics, path: path);
  }

  static _configureCache(GetIt getIt) async {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring cache");

    GetIt.instance.registerLazySingletonAsync<CacheSystem>(() async {
      final nextCacheSystem = CacheSystem();
      await nextCacheSystem.initialize();
      return nextCacheSystem;
    });

    return;
  }

  static _configureCookies(GetIt getIt) async {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring cookies");

    final directory = await getApplicationDocumentsDirectory();
    final path =
        "${directory.path}${Platform.pathSeparator}strawberry_data${Platform.pathSeparator}cookies${Platform.pathSeparator}";
    logger.trace("cookie path: $path");

    final cookieJar = PersistCookieJar(storage: FileStorage(path));
    getIt.registerSingleton<CookieJar>(cookieJar);
  }

  static _configureRepositories(GetIt getIt) {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring repositories");

    logger.trace("configuring image repository");
    getIt.registerLazySingleton<AbstractImageRepository>(
      () => ImageRepositoryImpl(),
    );

    logger.trace("configuring auth repository");
    getIt.registerLazySingleton<AbstractAuthRepository>(
      () => AuthRepositoryImpl(),
    );

    logger.trace("configuring qrcode repository");
    getIt.registerLazySingleton<AbstractQrCodeRepository>(
      () => QrCodeRepositoryImpl(),
    );

    logger.trace("configuring user avatar repository");
    getIt.registerLazySingleton<AbstractUserAvatarRepository>(
      () => UserAvatarRepositoryImpl(),
    );

    logger.trace("configuring user detail repository");
    getIt.registerLazySingleton<AbstractUserDetailRepository>(
      () => UserDetailRepositoryImpl(),
    );

    logger.trace("configuring playlist repository");
    getIt.registerLazySingleton<AbstractPlaylistRepository>(
      () => PlaylistRepositoryImpl(),
    );

    logger.trace("configuring playlists repository");
    getIt.registerLazySingleton<AbstractPlaylistsRepository>(
      () => PlaylistsRepositoryImpl(),
    );

    logger.trace("configuring song repository");
    getIt.registerLazySingleton<AbstractSongRepository>(
      () => SongRepositoryImpl(),
    );

    logger.trace("configuring album repository");
    getIt.registerLazySingleton<AbstractAlbumRepository>(
      () => AlbumRepositoryImpl(),
    );

    logger.trace("configuring user habit repository");
    getIt.registerLazySingleton<AbstractUserHabitRepository>(
      () => UserHabitRepositoryImpl(),
    );

    logger.trace("configuring search repository");
    getIt.registerLazySingleton<AbstractSearchRepository>(
      () => SearchRepositoryImpl(),
    );
  }
}
