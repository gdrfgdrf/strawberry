import 'dart:io';
import 'dart:isolate';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:natives/wrap/native_loader.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/configuration/desktop_config.dart';

import 'cookie_center_bean.dart';

class CookieCenter implements CookieJar {
  static final instance = CookieCenter._internal();
  static SendPort? cookieCenterPort;
  static DartStrawberryLogger? logger;

  CookieCenter._internal();

  /// main isolate owned
  static Future<void> initialize() async {
    final logger = GetIt.instance.get<DartStrawberryLogger>();
    logger.info("initialize cookie center");

    final receivePort = ReceivePort();
    final desktopConfig = GetIt.instance.get<DesktopConfig>();
    final token = RootIsolateToken.instance;

    logger.trace("spawning cookie center isolate");
    await Isolate.spawn(_cookieCenterIsolateEntry, {
      "send-port": receivePort.sendPort,
      "desktop-config": desktopConfig,
      "token": token,
    });
    cookieCenterPort = await receivePort.first as SendPort;
  }

  static void _cookieCenterIsolateEntry(Map<String, dynamic> parameter) async {
    final mainSendPort = parameter["send-port"];
    final desktopConfig = parameter["desktop-config"];
    final token = parameter["token"];
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);

    await initNative();
    await initLogger("CookieCenter");

    logger = GetIt.instance.get<DartStrawberryLogger>();
    logger!.trace("cookie center ready");

    final receivePort = ReceivePort();
    final cookieJar = await _prepareCookieJar(desktopConfig);

    mainSendPort.send(receivePort.sendPort);

    logger!.trace("cookie center initialized");

    receivePort.listen((request) async {
      request as CookieRequest;

      switch (request.action) {
        case CookieAction.load:
          {
            await _handleLoadAction(cookieJar, request);
          }
        case CookieAction.save:
          {
            await _handleSaveAction(cookieJar, request);
          }
        case CookieAction.delete:
          {
            await _handleDeleteAction(cookieJar, request);
          }
        case CookieAction.deleteAll:
          {
            await _handleDeleteAllAction(cookieJar, request);
          }
      }
    });
  }

  static Future<void> _handleLoadAction(
    CookieJar cookieJar,
    CookieRequest request,
  ) async {
    if (request.uri != null) {
      final uri = request.uri!;
      logger!.trace("loading cookies for uri: $uri");

      final cookies = await cookieJar.loadForRequest(uri);
      request.replyPort.send(cookies);
    }
  }

  static Future<void> _handleSaveAction(
    CookieJar cookieJar,
    CookieRequest request,
  ) async {
    if (request.uri != null && request.argument != null) {
      final uri = request.uri!;
      final argument = request.argument;
      logger!.trace(
        "saving cookies: ${argument.map((cookie) => cookie.name).toList()} for uri: $uri",
      );

      await cookieJar.saveFromResponse(uri, argument);
    }
    request.replyPort.send(null);
  }

  static Future<void> _handleDeleteAction(
    CookieJar cookieJar,
    CookieRequest request,
  ) async {
    if (request.uri != null && request.argument != null) {
      final uri = request.uri;
      logger!.trace("deleting cookies for $uri");

      await cookieJar.delete(request.uri!, request.argument);
    }
    request.replyPort.send(null);
  }

  static Future<void> _handleDeleteAllAction(
    CookieJar cookieJar,
    CookieRequest request,
  ) async {
    logger!.trace("deleting all cookies");
    await cookieJar.deleteAll();
    request.replyPort.send(null);
  }

  static Future<CookieJar> _prepareCookieJar(
    DesktopConfig desktopConfig,
  ) async {
    logger!.info("preparing cookie jar");

    final directory = await getApplicationDocumentsDirectory();
    final path =
        "${directory.path}${Platform.pathSeparator}strawberry_data${Platform.pathSeparator}cookies${Platform.pathSeparator}";

    logger!.trace("cookie path: $path");

    final cookieJar = PersistCookieJar(storage: FileStorage(path));

    final uri = Uri.parse("https://interface.music.163.com");
    final cookies = await cookieJar.loadForRequest(uri);

    logger!.trace("adding default cookies");
    cookies.addAll([
      Cookie("os", "pc"),
      Cookie("deviceId", desktopConfig.device.deviceId),
      Cookie("osver", desktopConfig.device.osVer),
      Cookie("appver", desktopConfig.client.appVer),
      Cookie("channel", "netease"),
    ]);

    logger!.trace("saving default cookies");
    cookieJar.saveFromResponse(
      Uri.parse("https://interface.music.163.com"),
      cookies,
    );

    return cookieJar;
  }

  @override
  Future<List<Cookie>> loadForRequest(Uri uri) async {
    final responsePort = ReceivePort();
    cookieCenterPort?.send(
      CookieRequest(CookieAction.load, uri, responsePort.sendPort, null),
    );
    final result = await responsePort.first;
    responsePort.close();

    if (result is List<Cookie>) {
      return result;
    }
    return [];
  }

  @override
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {
    final responsePort = ReceivePort();
    cookieCenterPort?.send(
      CookieRequest(CookieAction.save, uri, responsePort.sendPort, cookies),
    );
    await responsePort.first;
    responsePort.close();
  }

  @override
  Future<void> delete(Uri uri, [bool withDomainSharedCookie = false]) async {
    final responsePort = ReceivePort();
    cookieCenterPort?.send(
      CookieRequest(
        CookieAction.save,
        uri,
        responsePort.sendPort,
        withDomainSharedCookie,
      ),
    );
    await responsePort.first;
    responsePort.close();
  }

  @override
  Future<void> deleteAll() async {
    final responsePort = ReceivePort();
    cookieCenterPort?.send(
      CookieRequest(CookieAction.save, null, responsePort.sendPort, null),
    );
    await responsePort.first;
    responsePort.close();
  }

  @override
  bool get ignoreExpires => false;
}
