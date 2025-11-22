import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:domain/navigation_service.dart';
import 'package:domain/repository/album_repository.dart';
import 'package:domain/repository/auth_repository.dart';
import 'package:domain/repository/playlist/playlist_repository.dart';
import 'package:domain/repository/playlist/playlists_repository.dart';
import 'package:domain/repository/qr_code_repository.dart';
import 'package:domain/repository/search_repository.dart';
import 'package:domain/repository/song_repository.dart';
import 'package:domain/repository/user/user_avatar_repository.dart';
import 'package:domain/repository/user/user_detail_repository.dart';
import 'package:domain/repository/user_habit_repository.dart';
import 'package:domain/usecase/album_usecase.dart';
import 'package:domain/usecase/auth_usecase.dart';
import 'package:domain/usecase/playlist_usecase.dart';
import 'package:domain/usecase/playlists_usecase.dart';
import 'package:domain/usecase/qr_code_use_case.dart';
import 'package:domain/usecase/song_usecase.dart';
import 'package:domain/usecase/user_usecase.dart';
import 'package:domain/usecase/search_usecase.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/api/device.dart';
import 'package:shared/configuration/desktop_config.dart';
import 'package:shared/configuration/general_config.dart';
import 'package:shared/l10n/localizer.dart';
import 'package:strawberry/bloc/album/album_bloc.dart';
import 'package:strawberry/bloc/auth/auth_bloc.dart';
import 'package:strawberry/bloc/playlist/playlist_bloc.dart';
import 'package:strawberry/bloc/qrcode/qr_code_bloc.dart';
import 'package:strawberry/bloc/search/search_bloc.dart';
import 'package:strawberry/bloc/song/song_bloc.dart';
import 'package:strawberry/bloc/user/user_bloc.dart';
import 'package:strawberry/play/playlist_manager.dart';
import 'package:strawberry/ui/router/home_router.dart';
import 'package:strawberry/ui/router/main_router.dart';
import 'package:strawberry/ui/router/navigation_service.dart';
import 'package:widgets/floatingtoast/toast_center.dart';

class AppConfig {
  static final GlobalKey<NavigatorState> mainNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> homeNavigatorKey =
      GlobalKey<NavigatorState>();

  static void configure() {
    _configureGetIt();
  }

  static Future<void> configureConfigurations() async {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring configuration files");

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}${Platform.pathSeparator}strawberry_data";
    final pathDirectory = Directory(path);
    if (!await pathDirectory.exists()) {
      logger.trace("creating data folder: $path");
      await pathDirectory.create();
    }
    logger.trace("data folder: $path");

    final generalConfigFile = File("$path/general_config.json");
    if (!await generalConfigFile.exists()) {
      logger.trace("creating general_config.json");

      await generalConfigFile.create();

      final userAgent =
          "NeteaseMusic/9.3.0.250516233250(9003000);Dalvik/2.1.0 (Linux; U; Android 12; 513A154B Build/AB1C.112233.123)";
      final generalConfig = GeneralConfig(
        -1,
        userAgent,
        {
          "nm-gcore-status": "1",
          "mg-product-name": "music",
          "mconfig-info":
              "{\"IuRPVVmc3WWul9fT\":{\"version\":821248,\"appver\":\"2.10.13.202675\"}}",
        },
        DartLogLevel.runtime,
        DartLogLevel.runtime,
      );
      GetIt.instance.registerSingleton(generalConfig);

      logger.trace("writing general_config.json");
      generalConfigFile.writeAsString(generalConfig.toJson());
    } else {
      logger.trace("parsing general_config.json");

      final content = await generalConfigFile.readAsString();
      final generalConfig = GeneralConfig.parseJson(content);
      GetIt.instance.registerSingleton(generalConfig);
    }

    final desktopConfigFile = File("$path/desktop_config.json");
    if (!await desktopConfigFile.exists()) {
      logger.trace("creating desktop_config.json");

      await desktopConfigFile.create();

      final client = Client("2.10.13.202675");
      final clientSign = ClientSign(
        CodeGenerator.generateMac(),
        CodeGenerator.generateDeviceIdentifier(),
        CodeGenerator.generateDeviceUuid(),
      );
      final device = Device(
        "Microsoft-Windows-10-Professional-build-16541-64bit",
        CodeGenerator.generateDeviceId(),
      );

      final desktopConfig = DesktopConfig(clientSign, client, device);
      GetIt.instance.registerSingleton(desktopConfig);

      logger.trace("writing desktop_config.json");
      desktopConfigFile.writeAsString(desktopConfig.toJson());
    } else {
      logger.trace("parsing desktop_config.json");

      final content = await desktopConfigFile.readAsString();
      final desktopConfig = DesktopConfig.parseJson(content);
      GetIt.instance.registerSingleton(desktopConfig);
    }
  }

  static void _configureGetIt() {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring get it");

    final getIt = GetIt.instance;

    logger.trace("configuring localizer");
    getIt.registerLazySingleton<Localizer>(() {
      return Localizer.of(mainNavigatorKey.currentContext!)!;
    });

    _configureToastCenter(getIt);
    _configurePlayComponents(getIt);
    _configureNavigationGetIt(getIt);
    _configureUseCaseGetIt(getIt);
  }

  static void _configureToastCenter(GetIt getIt) {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring toast center");

    getIt.registerLazySingleton<ToastCenter>(() => ToastCenter());
  }

  static void _configurePlayComponents(GetIt getIt) {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring play components");

    final audioPlayer = AudioPlayer();
    GetIt.instance.registerSingleton<AudioPlayer>(audioPlayer);

    audioPlayer.errorStream.listen((error) {
      logger.error(
        "play error, index: ${error.index}: ${error.message}",
      );
      audioPlayer.seekToNext().catchError((e) {
        logger.error("seek next error: $e");
      });
    });

    logger.trace("configuring playlist manager singleton");
    getIt.registerLazySingleton<PlaylistManager>(() => PlaylistManagerImpl());
  }

  static void _configureNavigationGetIt(GetIt getIt) {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring navigations");

    logger.trace("configuring main router singleton");
    getIt.registerLazySingleton<MainRouter>(() => MainRouter()..initRouter());
    logger.trace("configuring home router singleton");
    getIt.registerLazySingleton<HomeRouter>(() => HomeRouter()..initRouter());

    logger.trace("configuring navigator creation");
    getIt.registerLazySingleton<NavigatorFactory>(() => NavigatorFactoryImpl());

    logger.trace("configuring main navigator creation");
    getIt.registerFactory<AbstractMainNavigator>(() {
      return getIt.get<NavigatorFactory>().createMain();
    });

    logger.trace("configuring home navigator creation");
    getIt.registerFactory<AbstractHomeNavigator>(() {
      return getIt.get<NavigatorFactory>().createHome();
    });
  }

  static void _configureUseCaseGetIt(GetIt getIt) {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("configuring usecases and blocs");

    logger.trace("configuring auth usecase singleton");
    getIt.registerLazySingleton<AuthUseCase>(
      () => AuthUseCaseImpl(getIt<AbstractAuthRepository>()),
    );

    logger.trace("configuring auth bloc creation");
    getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthUseCase>()));

    logger.trace("configuring qrcode usecase singleton");
    getIt.registerLazySingleton<QrCodeUseCase>(
      () => QrCodeUseCaseImpl(getIt<AbstractQrCodeRepository>()),
    );

    logger.trace("configuring qrcode bloc creation");
    getIt.registerFactory<QrCodeBloc>(() => QrCodeBloc(getIt<QrCodeUseCase>()));

    logger.trace("configuring user usecase singleton");
    getIt.registerLazySingleton<UserUseCase>(
      () => UserUseCaseImpl(
        getIt<AbstractUserDetailRepository>(),
        getIt<AbstractUserAvatarRepository>(),
        getIt<AbstractUserHabitRepository>()
      ),
    );

    logger.trace("configuring user bloc creation");
    getIt.registerFactory<UserBloc>(() => UserBloc(getIt<UserUseCase>()));

    logger.trace("configuring playlist usecase singleton");
    getIt.registerLazySingleton<PlaylistUseCase>(
      () => PlaylistUseCaseImpl(getIt<AbstractPlaylistRepository>()),
    );

    logger.trace("configuring playlists usecase singleton");
    getIt.registerLazySingleton<PlaylistsUseCase>(
      () => PlaylistsUseCaseImpl(getIt<AbstractPlaylistsRepository>()),
    );

    logger.trace("configuring playlists bloc creation");
    getIt.registerFactory<PlaylistBloc>(
      () => PlaylistBloc(getIt<PlaylistsUseCase>(), getIt<PlaylistUseCase>()),
    );

    logger.trace("configuring song usecase singleton");
    getIt.registerLazySingleton<SongUseCase>(
      () => SongUseCaseImpl(getIt<AbstractSongRepository>()),
    );

    logger.trace("configuring song bloc creation");
    getIt.registerFactory<SongBloc>(() => SongBloc(getIt<SongUseCase>()));

    logger.trace("configuring album usecase singleton");
    getIt.registerLazySingleton<AlbumUseCase>(
      () => AlbumUseCaseImpl(getIt<AbstractAlbumRepository>()),
    );

    logger.trace("configuring album bloc creation");
    getIt.registerFactory<AlbumBloc>(() => AlbumBloc(getIt<AlbumUseCase>()));
    
    logger.trace("configuring search usecase singleton");
    getIt.registerLazySingleton<SearchUseCase>(() => SearchUseCaseImpl(getIt<AbstractSearchRepository>()));
    
    logger.trace("configuring search bloc creation");
    getIt.registerFactory<SearchBloc>(() => SearchBloc(getIt<SearchUseCase>()));
  }
}
