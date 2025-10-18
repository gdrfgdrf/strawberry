import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:data/center/cookie_center.dart';
import 'package:data/isolatepool/stream/task_stream.dart';
import 'package:data/isolatepool/tasks/network_task_impl.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mutex/mutex.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';
import 'package:pair/pair.dart';
import 'package:shared/configuration/general_config.dart';

import 'isolate_executor.dart';
import 'isolate_pool_bean.dart';

class IsolatePool {
  static const Map<IsolateType, String> _typeNames = {
    IsolateType.network: 'Network',
    IsolateType.imageNetwork: "ImageNetwork",
    IsolateType.file: 'File',
  };
  static final Map<IsolateType, int> _isolateCounts = {};

  final Map<IsolateType, Map<String, IsolateWorker>> _workers = {};
  final Map<IsolateType, Queue<Completer<IsolateWorker?>>> _pendingRequests =
      {};
  final Map<String, Pair<DataReceiver?, ErrorReceiver?>> _receivers = {};

  final ReceivePort _mainReceivePort = ReceivePort();
  DartStrawberryServiceLogger serviceLogger = openService("IsolatePoolManager");

  int taskPerSecond = 0;
  int _taskSubmitCount = 0;
  Timer? _taskResetTimer;

  Mutex submitMutex = Mutex();

  IsolatePool() {
    _taskResetTimer = Timer.periodic(Duration(seconds: 1), (_) {
      taskPerSecond = _taskSubmitCount;
      _taskSubmitCount = 0;
    });

    final total = IsolateType.values
        .map((type) => type.portion)
        .toList()
        .fold(0, (sum, i) => i + sum);

    for (final type in IsolateType.values) {
      _workers[type] = {};
      _pendingRequests[type] = Queue();

      final count = _calculateIsolateCount(type, total);
      _isolateCounts[type] = count;

      serviceLogger.info("will spawn $count isolate(s) for type $type");
    }
  }

  static int _calculateIsolateCount(IsolateType type, int total) {
    final coreCount = Platform.numberOfProcessors;
    final result = (coreCount * type.portion / total).round();
    final value = min(result <= 0 ? 1 : result, type.max);

    if (value <= type.min) {
      return type.min;
    }
    return value;
  }

  Future<void> initializeIsolates() async {
    for (final type in IsolateType.values) {
      final baseName = _typeNames[type]!;
      final count = _isolateCounts[type]!;

      for (int i = 0; i < count; i++) {
        await _spawnIsolate(type, '$baseName-$i');
      }
    }
  }

  Future<void> _spawnIsolate(IsolateType type, String name) async {
    final generalConfig = GetIt.instance.get<GeneralConfig>();
    final receivePort = ReceivePort();
    final completer = Completer<SendPort>();

    serviceLogger.info("spawning $name");
    await Isolate.spawn(isolateEntry, {
      "send-port": receivePort.sendPort,
      "token": RootIsolateToken.instance,
      "cookie-center-send-port": CookieCenter.cookieCenterPort,
      "log-immediate-flush": generalConfig.logImmediateFlush,
      "log-enabled-levels": generalConfig.logEnabledLevels,
    }, debugName: name);

    SendPort? workerSendPort;

    receivePort.listen((action) {
      action as Action;

      if (action.type == Actions.isolateReady) {
        serviceLogger.info("$name is ready");

        final content = action.content as SendPort;
        completer.complete(content);
        return;
      }
      if (action.type == Actions.isolateInitialized) {
        serviceLogger.info("$name is initialized");

        final worker = IsolateWorker(
          type: type,
          name: name,
          isIdle: true,
          sendPort: workerSendPort!,
          receivePort: receivePort,
        );

        _workers[type]![name] = worker;
        return;
      }
      if (action.type == Actions.isolateTaskFinished &&
          action is ResultAction) {
        _handleIsolateTaskSuccess(action);
        _checkPendingRequests(action.isolateType);
        return;
      }
      if (action.type == Actions.isolateTaskError && action is ErrorAction) {
        _handleIsolateTaskError(action);
        _checkPendingRequests(action.isolateType);
        return;
      }
    });

    dynamic initParam;
    if (type == IsolateType.network || type == IsolateType.imageNetwork) {
      initParam = buildNetworkInitParam();
    }

    workerSendPort = await completer.future;
    serviceLogger.info("sending init action to $name");
    workerSendPort.send(
      Actions.init.createAction(content: Pair(type, initParam)),
    );
  }

  void _handleIsolateTaskSuccess(ResultAction action) {
    final isolateType = action.isolateType;
    final isolateName = action.isolateName;
    final id = action.id;
    final result = action.buffer;

    serviceLogger.trace(
      "task finished, id: $id, type: $isolateType, name: $isolateName",
    );

    final worker = _workers[isolateType]?[isolateName];
    if (worker == null) {
      return;
    }

    serviceLogger.trace(
      "task finish, worker type: $isolateType, name: $isolateName, is idle: ${worker.isIdle}, task count: ${worker.taskCount.get_()}",
    );
    worker.taskFinished();

    _receivers[id]?.key?.call(result?.materialize().asUint8List());
    _receivers.remove(id);
  }

  void _handleIsolateTaskError(ErrorAction action) {
    final isolateType = action.isolateType;
    final isolateName = action.isolateName;
    final id = action.id;
    final error = action.error;
    final stackTrace = action.stackTrace;

    serviceLogger.error(
      "task error, id: $id, type: $isolateType, name: $isolateName, error: $error\n$stackTrace",
    );

    final worker = _workers[isolateType]?[isolateName];
    if (worker == null) {
      return;
    }

    serviceLogger.trace(
      "task error, worker type: $isolateType, name: $isolateName is idle: ${worker.isIdle}, task count: ${worker.taskCount.get_()}",
    );
    worker.taskFinished();

    _receivers[id]?.value?.call(error, stackTrace);
  }

  Future<void> submitStream(StreamTask task) async {
    serviceLogger.trace(
      "submitting a stream task, id: ${task.id}, type: ${task.type}, timeout: ${task.timeout.inMilliseconds}ms",
    );
    _taskSubmitCount++;

    final type = task.type;
    final worker = await _getIdleWorker(type, task.timeout);
    if (worker == null) {
      throw StateError("there are no more idle workers");
    }

    final controller = StreamController<TransferableTypedData>();
    task.provideStream(controller.stream);

    serviceLogger.trace(
      "worker type: ${worker.type}, name: ${worker.name}, is idle: ${worker.isIdle}, task count: ${worker.taskCount.get_()}",
    );
    worker.taskSubmitted();

    final receivePort = ReceivePort();
    final streamProvider = StreamProvider(receivePort);
    streamProvider.listen(
      controller,
      onClose: (signal) {
        final isolateType = worker.type;
        final isolateName = worker.name;

        if (signal.failure != null) {
          serviceLogger.error(
            "stream task error, worker type: $isolateType, name: $isolateName: ${signal.failure!.error}\n${signal.failure!.stackTrace}",
          );
        }

        serviceLogger.trace(
          "stream task finish, worker type: $isolateType, name: $isolateName, is idle: ${worker.isIdle}, task count: ${worker.taskCount.get_()}",
        );
        worker.taskFinished();
        _checkPendingRequests(isolateType);
      },
    );

    final action = Actions.submitStreamTask.submitStreamAction(
      task.id,
      receivePort.sendPort,
      buffer:
          task.inputBuffer != null
              ? TransferableTypedData.fromList([task.inputBuffer!])
              : null,
    );

    serviceLogger.trace(
      "sending a stream task to worker, type: ${worker.type}, name: ${worker.name}",
    );
    worker.sendPort.send(action);
  }

  Future<void> submitTask(Task task) async {
    await submitMutex.acquire();

    serviceLogger.trace(
      "submitting a task, id: ${task.id}, type: ${task.type}, timeout: ${task.timeout.inMilliseconds}ms",
    );

    _taskSubmitCount++;

    final type = task.type;
    final worker = await _getIdleWorker(type, task.timeout);
    if (worker == null) {
      submitMutex.release();
      throw StateError("there are no more idle workers");
    }

    _receivers[task.id] = Pair(task.onComplete, task.onError);

    serviceLogger.trace(
      "worker type: ${worker.type}, name: ${worker.name}, is idle: ${worker.isIdle}, task count: ${worker.taskCount.get_()}",
    );
    worker.taskSubmitted();

    final action = Actions.submitTask.submitAction(
      task.id,
      buffer:
          task.inputBuffer != null
              ? TransferableTypedData.fromList([task.inputBuffer!])
              : null,
    );

    serviceLogger.trace(
      "sending a task to worker, type: ${worker.type}, name: ${worker.name}",
    );
    worker.sendPort.send(action);

    submitMutex.release();
  }

  Future<IsolateWorker?> _getIdleWorker(
    IsolateType type,
    Duration timeout,
  ) async {
    for (final worker in _workers[type]!.values) {
      if (worker.isIdle) {
        return worker;
      }
    }
    serviceLogger.trace(
      "adding a pending request to find a idle worker, type: $type, timeout: ${timeout.inMilliseconds}ms",
    );
    final completer = Completer<IsolateWorker?>();
    _pendingRequests[type]!.add(completer);

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        serviceLogger.trace(
          "waiting a idle worker timeout, type: $type, timeout: ${timeout.inMilliseconds}ms",
        );
        _pendingRequests[type]!.remove(completer);
        return null;
      },
    );
  }

  void _checkPendingRequests(IsolateType type) {
    serviceLogger.trace("checking pending requests");

    final queue = _pendingRequests[type]!;
    if (queue.isNotEmpty) {
      for (final worker in _workers[type]!.values) {
        if (worker.isIdle) {
          serviceLogger.trace(
            "worker is idle, completing a pending request, type: $type, name: ${worker.name}",
          );

          final completer = queue.removeFirst();
          completer.complete(worker);
          return;
        }
      }
    }
  }

  void dispose() {
    serviceLogger.info("disposing");
    serviceLogger.goodbye();

    _taskResetTimer?.cancel();
    _mainReceivePort.close();
    for (final workers in _workers.values) {
      for (final worker in workers.values) {
        worker.receivePort.close();
        worker.sendPort.send(Actions.shutdown.createAction());
      }
    }
  }
}
