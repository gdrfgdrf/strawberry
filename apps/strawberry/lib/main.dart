import 'package:audio_service/audio_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:initializer/initializer.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:natives/wrap/native_loader.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/configuration/general_config.dart';
import 'package:shared/l10n/localizer.dart';
import 'package:shared/platform_extension.dart';
import 'package:shared/themes.dart';
import 'package:strawberry/app_config.dart';
import 'package:strawberry/play/platform_specific_controller.dart';
import 'package:strawberry/play/playlist_manager.dart';
import 'package:strawberry/ui/router/main_router.dart';
import 'package:widgets/widgets/dispose_detector.dart';
import 'package:window_manager/window_manager.dart';

Future<void> loggerTest() async {
  final folder =
      "${(await getApplicationDocumentsDirectory()).path}/strawberry_data/logs";
  final logger = DartStrawberryLogger(folder, "EfficientLoggerTest");
  logger.trace("dart test trace");
  logger.debug("dart test debug");
  logger.info("dart test info");
  logger.warn("dart test warn");
  logger.error("dart test error");
  logger.fatal("dart test fatal");

  final serviceLogger = logger.openService("EfficientServiceLoggerTest");
  serviceLogger.trace("service test trace");
  serviceLogger.debug("service test debug");
  serviceLogger.info("service test info");
  serviceLogger.warn("service test warn");
  serviceLogger.error("service test error");
  serviceLogger.fatal("service test fatal");

  final stopWatch = Stopwatch();
  stopWatch.start();

  for (var i = 0; i < 5000; i++) {
    logger.info("efficient rotation test: $i");
  }

  stopWatch.stop();
  print("efficient rotation test costs: ${stopWatch.elapsedMilliseconds}ms");
  stopWatch.reset();
  stopWatch.start();

  for (var i = 0; i < 5000; i++) {
    serviceLogger.info("service efficient rotation test: $i");
  }
  stopWatch.stop();

  print(
    'efficient service rotation test costs: ${stopWatch.elapsedMilliseconds}ms',
  );

  logger.goodbye();
  serviceLogger.goodbye();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initNative();
  EfficientLogger.initialize();
  EfficientLogger.deleteTimeoutLogFiles(
    "${(await getApplicationDocumentsDirectory()).path}/strawberry_data/logs",
    Duration(days: 3),
  );

  await initLogger("MainIsolate");

  final logger = GetIt.instance.get<DartStrawberryLogger>();

  BackgroundIsolateBinaryMessenger.ensureInitialized(
    ServicesBinding.rootIsolateToken!,
  );

  await AppInitializer.init();
  await AppConfig.configureConfigurations();

  final generalConfig = GetIt.instance.get<GeneralConfig>();
  // EfficientLogger.setImmediateFlush(generalConfig.logImmediateFlush);
  EfficientLogger.setImmediateFlush(DartLogLevel.debug_);
  // EfficientLogger.setEnabledLevels(generalConfig.logEnabledLevels);
  EfficientLogger.setEnabledLevels(DartLogLevel.debug_);

  JustAudioMediaKit.title = "Strawberry";
  JustAudioMediaKit.ensureInitialized();

  await AppInitializer.initHive();
  AppConfig.configure();
  await AppInitializer.initCookieCenter();
  await AppInitializer.initIsolatePool();

  if (PlatformExtension.isDesktop) {
    await WindowManager.instance.ensureInitialized();

    final windowOptions = WindowOptions();
    WindowManager.instance.waitUntilReadyToShow(windowOptions, () async {
      logger.info("set minimum size to 306 x 486");
      await WindowManager.instance.setMinimumSize(Size(306, 486));
      await WindowManager.instance.show();
      await WindowManager.instance.focus();
    });
  }

  await PlatformSpecificController.auto()?.prepare();

  runApp(Strawberry());
}

class Strawberry extends StatelessWidget {
  final logger = GetIt.instance.get<DartStrawberryLogger>();

  Strawberry({super.key});

  @override
  Widget build(BuildContext context) {
    Size designSize;
    if (PlatformExtension.isDesktop) {
      /// desktop in figma
      designSize = Size(1440, 1024);
    } else {
      /// iphone 16 in figma
      designSize = Size(393, 852);
    }
    logger.info("design size: ${designSize.width} x ${designSize.height}");

    return ScreenUtilInit(
      designSize: designSize,
      builder: (_, _) {
        final realLightColorScheme = defaultLightColorScheme.copyWith(
          surfaceTint: Colors.transparent,
        );
        final realDarkColorScheme = defaultDarkColorScheme.copyWith(
          surfaceTint: Colors.transparent,
        );

        ThemeData lightTheme = ThemeData(
          textTheme: Theme.of(
            context,
          ).textTheme.apply(bodyColor: realLightColorScheme.onSurfaceVariant),
          colorScheme: realLightColorScheme,
          useMaterial3: true,
        );
        ThemeData darkTheme = ThemeData(
          textTheme: Theme.of(
            context,
          ).textTheme.apply(bodyColor: realDarkColorScheme.onSurfaceVariant),
          colorScheme: realDarkColorScheme,
          useMaterial3: true,
        );
        if (isDarkMode()) {
          logger.trace("update dark theme data");
          updateThemeData(darkTheme);
        } else {
          logger.trace("update light theme data");
          updateThemeData(lightTheme);
        }

        return DisposeDetector(
          child: MaterialApp(
            title: 'Strawberry',
            scrollBehavior: StrawberryScrollBehavior(),
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            navigatorKey: AppConfig.mainNavigatorKey,
            onGenerateRoute: GetIt.instance.get<MainRouter>().router.generator,
            localizationsDelegates: [
              Localizer.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: Localizer.supportedLocales,
          ),
          onDispose: () {
            EfficientLogger.goodbyeAll();
          },
        );
      },
    );
  }
}

class StrawberryScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
