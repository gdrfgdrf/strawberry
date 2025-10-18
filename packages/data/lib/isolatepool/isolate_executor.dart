import 'dart:isolate';

import 'package:data/isolatepool/tasks/network_task_impl.dart';
import 'package:data/isolatepool/tasks/task_dispatcher.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:natives/wrap/native_loader.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:pair/pair.dart';

import '../center/cookie_center.dart';
import 'isolate_pool_bean.dart';

DartStrawberryLogger? logger;

void isolateEntry(Map<String, dynamic> parameter) async {
  final mainSendPort = parameter["send-port"];
  final token = parameter["token"];
  final cookieCenterSendPort = parameter["cookie-center-send-port"];
  final logImmediateFlush = parameter["log-immediate-flush"];
  final logEnabledLevels = parameter["log-enabled-levels"];

  CookieCenter.cookieCenterPort = cookieCenterSendPort;

  BackgroundIsolateBinaryMessenger.ensureInitialized(token);

  await initNative();
  await initLogger(Isolate.current.debugName!);
  // EfficientLogger.setImmediateFlush(logImmediateFlush);
  EfficientLogger.setImmediateFlush(DartLogLevel.debug_);
  // EfficientLogger.setEnabledLevels(logEnabledLevels);
  EfficientLogger.setEnabledLevels(DartLogLevel.debug_);
  logger = GetIt.instance.get<DartStrawberryLogger>();

  final receivePort = ReceivePort();
  logger!.info("sending ready action to isolate manager");
  mainSendPort.send(
    Actions.isolateReady.createAction(content: receivePort.sendPort),
  );

  IsolateType? isolateType;
  receivePort.listen((action) async {
    action as Action;

    if (action.type == Actions.init) {
      logger!.info("init action from isolate manager is received");

      final pair = action.content as Pair<IsolateType, dynamic>;
      isolateType = pair.key;
      _isolateInit(isolateType!, pair.value);

      logger!.info("sending initialized action to isolate manager");
      mainSendPort.send(Actions.isolateInitialized.createAction());
      return;
    }
    if (action.type == Actions.submitTask && action is SubmitAction) {
      _handleSubmitTaskAction(mainSendPort, isolateType!, action);
    }
    if (action.type == Actions.submitStreamTask && action is SubmitStreamAction) {
      _handleSubmitStreamTaskAction(mainSendPort, isolateType!, action);
    }
  });
}

void _isolateInit(
  IsolateType type,
  dynamic initParam,
) {
  logger!.info("initializing isolate: $type");

  switch (type) {
    case IsolateType.network:
      {
        isolateInitNetwork(initParam);
      }
    case IsolateType.imageNetwork:
      {
        isolateInitNetwork(initParam);
      }
    case IsolateType.file:
      {}
  }
}

void _handleSubmitStreamTaskAction(
    SendPort mainSendPort,
    IsolateType isolateType,
    SubmitStreamAction action
) async {
  final id = action.id;

  logger!.trace("stream task received, id: $id");

  final buffer = action.buffer;
  final inputBuffer = buffer?.materialize().asUint8List();

  try {
    logger!.trace("dispatching a stream task, id: $id");
    dispatchStreamTask(id, isolateType, inputBuffer, action.sendPort);
  } catch (e, s) {
    logger!.error("stream task error, id: $id, error: $e\n$s");
  }
}

void _handleSubmitTaskAction(
  SendPort mainSendPort,
  IsolateType isolateType,
  SubmitAction action,
) async {
  final id = action.id;

  logger!.trace("task received, id: $id");

  final buffer = action.buffer;
  final inputBuffer = buffer?.materialize().asUint8List();

  try {
    logger!.trace("dispatching a task, id: $id");
    final result = await dispatchTask(id, isolateType, inputBuffer);

    logger!.trace("sending a task finished action to isolate manager, id: $id");
    mainSendPort.send(
      Actions.isolateTaskFinished.resultAction(
        id,
        result != null ? TransferableTypedData.fromList([result]) : null,
        isolateType,
        Isolate.current.debugName!,
      ),
    );
  } catch (e, s) {
    logger!.error("task error, id: $id, error: $e\n$s");

    logger!.trace("sending a task error action to isolate manager, id: $id");
    mainSendPort.send(
      Actions.isolateTaskError.errorAction(
        id,
        e,
        s,
        isolateType,
        Isolate.current.debugName!,
      ),
    );
  }
}
