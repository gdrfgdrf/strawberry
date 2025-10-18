import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import 'native_loader.dart';

Future<void> initLogger(String name) async {
  if (!GetIt.instance.isRegistered<DynamicLibrary>()) {
    return;
  }
  if (GetIt.instance.isRegistered<DartStrawberryLogger>()) {
    return;
  }

  final folder =
      "${(await getApplicationDocumentsDirectory()).path}/strawberry_data/logs";
  final logger = DartStrawberryLogger(folder, name);
  GetIt.instance.registerSingleton<DartStrawberryLogger>(logger);
}

DartStrawberryServiceLogger openService(String serviceName) {
  String actualServiceName = serviceName;

  if (serviceName.contains("-") && serviceName.contains("_")) {
    final split = serviceName.split("-");
    final first = split[0];
    final last = split[1];
    if (last.startsWith("_")) {
      actualServiceName = "$first-${last.substring(1)}";
    }
  }

  final logger = GetIt.instance.get<DartStrawberryLogger>();
  return logger.openService(actualServiceName);
}

class DartLogLevel {
  static const int trace = 0;
  static const int debug = 1;
  static const int info = 2;
  static const int warn = 3;
  static const int error = 4;
  static const int fatal = 5;

  static const List<int> all = debug_;
  static const List<int> runtime = [debug, error, fatal];
  static const List<int> debug_ = [trace, debug, info, warn, error, fatal];
}

class DartStrawberryLogger {
  final String folder;
  final String channelName;
  EfficientLogger? efficientLogger;

  DartStrawberryLogger(this.folder, this.channelName) {
    final library = GetIt.instance.get<DynamicLibrary>();
    efficientLogger = EfficientLogger(library);
  }

  void trace(String string) {
    efficientLogger!.trace(folder, channelName, string);
  }

  void debug(String string) {
    efficientLogger!.debug(folder, channelName, string);
  }

  void info(String string) {
    efficientLogger!.info(folder, channelName, string);
  }

  void warn(String string) {
    efficientLogger!.warn(folder, channelName, string);
  }

  void error(String string) {
    efficientLogger!.error(folder, channelName, string);
  }

  void fatal(String string) {
    efficientLogger!.fatal(folder, channelName, string);
  }

  DartStrawberryServiceLogger openService(String serviceName) {
    return DartStrawberryServiceLogger(folder, channelName, serviceName);
  }

  void goodbye() {
    efficientLogger!.goodbye(channelName);
  }

  void goodbyeService(String serviceName) {
    efficientLogger!.serviceGoodbye(channelName, serviceName);
  }
}

class DartStrawberryServiceLogger {
  final String folder;
  final String channelName;
  final String serviceName;
  EfficientLogger? efficientLogger;

  DartStrawberryServiceLogger(this.folder, this.channelName, this.serviceName) {
    final library = GetIt.instance.get<DynamicLibrary>();
    efficientLogger = EfficientLogger(library);
  }

  void trace(String string) {
    efficientLogger!.serviceTrace(folder, channelName, serviceName, string);
  }

  void debug(String string) {
    efficientLogger!.serviceDebug(folder, channelName, serviceName, string);
  }

  void info(String string) {
    efficientLogger!.serviceInfo(folder, channelName, serviceName, string);
  }

  void warn(String string) {
    efficientLogger!.serviceWarn(folder, channelName, serviceName, string);
  }

  void error(String string) {
    efficientLogger!.serviceError(folder, channelName, serviceName, string);
  }

  void fatal(String string) {
    efficientLogger!.serviceFatal(folder, channelName, serviceName, string);
  }

  void goodbye() {
    efficientLogger!.serviceGoodbye(channelName, serviceName);
  }
}

class EfficientLogger {
  final DynamicLibrary _nativeLib;

  static void Function()? _initialize;
  static void Function(Pointer<Uint8>, int, int)? _deleteTimeoutLogFiles;
  static void Function(Pointer<Uint8>, int)? _setImmediateFlush;
  static void Function(Pointer<Uint8>, int)? _setEnabledLevels;
  static void Function()? _goodbyeAll;
  static void Function(int, Pointer<Uint8>, int, Pointer<Uint8>, int)?
  _goodbyeLog;
  static void Function(
    int,
    Pointer<Uint8>,
    int,
    Pointer<Uint8>,
    int,
    Pointer<Uint8>,
    int,
    int,
    Pointer<Uint8>,
    int,
  )?
  _efficientLog;

  EfficientLogger(this._nativeLib) {
    findFunctions(_nativeLib);
  }

  static void initialize() {
    final library = GetIt.instance.get<DynamicLibrary>();
    findFunctions(library);

    _initialize!();
  }

  static void deleteTimeoutLogFiles(String folder, Duration timeout) {
    final library = GetIt.instance.get<DynamicLibrary>();
    findFunctions(library);

    final timeoutDay = timeout.inDays;
    final folderData = Uint8List.fromList(utf8.encode(folder));
    final folderLen = folder.length;
    final folderPtr = createBuffer!(folderLen);
    folderPtr.asTypedList(folderLen).setAll(0, folderData);

    _deleteTimeoutLogFiles!(folderPtr, folderLen, timeoutDay);
    releaseBuffer!(folderPtr, folderLen);
  }

  static void setImmediateFlush(List<int> levels) {
    final library = GetIt.instance.get<DynamicLibrary>();
    findFunctions(library);

    final len = levels.length;
    final ptr = createBuffer!(len * 4);
    for (int i = 0; i < len; i++) {
      (ptr + i * 4).cast<Int32>().value = levels[i];
    }

    _setImmediateFlush!(ptr, len);
    releaseBuffer!(ptr, len);
  }

  static void setEnabledLevels(List<int> levels) {
    final library = GetIt.instance.get<DynamicLibrary>();
    findFunctions(library);

    final len = levels.length;
    final ptr = createBuffer!(len * 4);
    for (int i = 0; i < len; i++) {
      (ptr + i * 4).cast<Int32>().value = levels[i];
    }

    _setEnabledLevels!(ptr, len);
    releaseBuffer!(ptr, len);
  }

  static void goodbyeAll() {
    final library = GetIt.instance.get<DynamicLibrary>();
    findFunctions(library);

    _goodbyeAll!();
  }

  static void findFunctions(DynamicLibrary library) {
    _initialize ??= library.lookupFunction<Void Function(), void Function()>(
      "initialize_log",
    );

    _deleteTimeoutLogFiles ??= library.lookupFunction<
      Void Function(Pointer<Uint8>, Uint32, Uint32),
      void Function(Pointer<Uint8>, int, int)
    >("delete_timeout_log_files");

    _setImmediateFlush ??= library.lookupFunction<
      Void Function(Pointer<Uint8>, Uint32),
      void Function(Pointer<Uint8>, int)
    >("set_immediate_flush");

    _setEnabledLevels ??= library.lookupFunction<
      Void Function(Pointer<Uint8>, Uint32),
      void Function(Pointer<Uint8>, int)
    >("set_enabled_levels");

    _goodbyeAll ??= library.lookupFunction<Void Function(), void Function()>(
      "goodbye_all",
    );

    _goodbyeLog ??= library.lookupFunction<
      Void Function(Uint32, Pointer<Uint8>, Uint32, Pointer<Uint8>, Uint32),
      void Function(int, Pointer<Uint8>, int, Pointer<Uint8>, int)
    >("goodbye_log");

    _efficientLog ??= library.lookupFunction<
      Void Function(
        Uint32,
        Pointer<Uint8>,
        Uint32,
        Pointer<Uint8>,
        Uint32,
        Pointer<Uint8>,
        Uint32,
        Uint32,
        Pointer<Uint8>,
        Uint32,
      ),
      void Function(
        int,
        Pointer<Uint8>,
        int,
        Pointer<Uint8>,
        int,
        Pointer<Uint8>,
        int,
        int,
        Pointer<Uint8>,
        int,
      )
    >("efficient_log");
  }

  void _goodbye(int loggerType, String channelName, String? serviceName) {
    final channelNameData = Uint8List.fromList(utf8.encode(channelName));
    final channelNameLen = channelNameData.length;
    final channelNamePtr = createBuffer!(channelNameLen);
    channelNamePtr.asTypedList(channelNameLen).setAll(0, channelNameData);

    Pointer<Uint8>? serviceNamePtr;
    int serviceNameLen = 0;

    if (serviceName != null) {
      final serviceNameData = Uint8List.fromList(utf8.encode(serviceName));
      serviceNameLen = serviceNameData.length;
      serviceNamePtr = createBuffer!(serviceNameLen);
      serviceNamePtr.asTypedList(serviceNameLen).setAll(0, serviceNameData);
    }

    _goodbyeLog!(
      loggerType,
      channelNamePtr,
      channelNameLen,
      serviceNamePtr ?? Pointer<Uint8>.fromAddress(0),
      serviceNameLen,
    );
    releaseBuffer!(channelNamePtr, channelNameLen);
    if (serviceNamePtr != null) {
      releaseBuffer!(serviceNamePtr, serviceNameLen);
    }
  }

  void _log(
    int loggerType,
    String folder,
    String channelName,
    String? serviceName,
    int level,
    String message,
  ) {
    final folderData = Uint8List.fromList(utf8.encode(folder));
    final folderLen = folderData.length;
    final folderPtr = createBuffer!(folderLen);
    folderPtr.asTypedList(folderLen).setAll(0, folderData);

    final channelNameData = Uint8List.fromList(utf8.encode(channelName));
    final channelNameLen = channelNameData.length;
    final channelNamePtr = createBuffer!(channelNameLen);
    channelNamePtr.asTypedList(channelNameLen).setAll(0, channelNameData);

    Pointer<Uint8>? serviceNamePtr;
    int serviceNameLen = 0;

    if (serviceName != null) {
      final serviceNameData = Uint8List.fromList(utf8.encode(serviceName));
      serviceNameLen = serviceNameData.length;
      serviceNamePtr = createBuffer!(serviceNameLen);
      serviceNamePtr.asTypedList(serviceNameLen).setAll(0, serviceNameData);
    }

    final messageData = Uint8List.fromList(utf8.encode(message));
    final messageLen = messageData.length;
    final messagePtr = createBuffer!(messageLen);
    messagePtr.asTypedList(messageLen).setAll(0, messageData);

    _efficientLog!(
      loggerType,
      folderPtr,
      folderLen,
      channelNamePtr,
      channelNameLen,
      serviceNamePtr ?? nullptr,
      serviceNameLen,
      level,
      messagePtr,
      messageLen,
    );

    releaseBuffer!(folderPtr, folderLen);
    releaseBuffer!(channelNamePtr, channelNameLen);
    if (serviceNamePtr != null) {
      releaseBuffer!(serviceNamePtr, serviceNameLen);
    }
    releaseBuffer!(messagePtr, messageLen);
  }

  void trace(String folder, String channelName, String string) =>
      _log(0, folder, channelName, null, DartLogLevel.trace, string);

  void debug(String folder, String channelName, String string) =>
      _log(0, folder, channelName, null, DartLogLevel.debug, string);

  void info(String folder, String channelName, String string) =>
      _log(0, folder, channelName, null, DartLogLevel.info, string);

  void warn(String folder, String channelName, String string) =>
      _log(0, folder, channelName, null, DartLogLevel.warn, string);

  void error(String folder, String channelName, String string) =>
      _log(0, folder, channelName, null, DartLogLevel.error, string);

  void fatal(String folder, String channelName, String string) =>
      _log(0, folder, channelName, null, DartLogLevel.fatal, string);

  void goodbye(String channelName) => _goodbye(0, channelName, null);

  void serviceTrace(
    String folder,
    String channelName,
    String serviceName,
    String string,
  ) => _log(1, folder, channelName, serviceName, DartLogLevel.trace, string);

  void serviceDebug(
    String folder,
    String channelName,
    String serviceName,
    String string,
  ) => _log(1, folder, channelName, serviceName, DartLogLevel.debug, string);

  void serviceInfo(
    String folder,
    String channelName,
    String serviceName,
    String string,
  ) => _log(1, folder, channelName, serviceName, DartLogLevel.info, string);

  void serviceWarn(
    String folder,
    String channelName,
    String serviceName,
    String string,
  ) => _log(1, folder, channelName, serviceName, DartLogLevel.warn, string);

  void serviceError(
    String folder,
    String channelName,
    String serviceName,
    String string,
  ) => _log(1, folder, channelName, serviceName, DartLogLevel.error, string);

  void serviceFatal(
    String folder,
    String channelName,
    String serviceName,
    String string,
  ) => _log(1, folder, channelName, serviceName, DartLogLevel.fatal, string);

  void serviceGoodbye(String channelName, String serviceName) =>
      _goodbye(1, channelName, serviceName);
}
