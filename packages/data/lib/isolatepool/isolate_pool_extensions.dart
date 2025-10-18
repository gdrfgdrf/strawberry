import 'dart:convert';
import 'dart:isolate';

import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/isolate_pool_bean.dart';
import 'package:data/isolatepool/isolate_pool_manager.dart';
import 'package:data/isolatepool/tasks/file_task_impl.dart';
import 'package:get_it/get_it.dart';

void sendBinaryNetwork(
  Endpoint endpoint,
  void Function(List<int>) onComplete,
  void Function(dynamic, StackTrace)? onError,
) {
  final isolatePool = GetIt.instance.get<IsolatePool>();
  isolatePool.submitTask(
    Task.uuid(
      type: IsolateType.network,
      inputBuffer: endpoint.writeBuffer(),
      onComplete: (data) {
        onComplete(data!);
      },
      onError: onError,
    ),
  );
}

void sendStringNetwork(
  Endpoint endpoint,
  void Function(String) onComplete,
  void Function(dynamic, StackTrace)? onError,
) {
  final isolatePool = GetIt.instance.get<IsolatePool>();
  isolatePool.submitTask(
    Task.uuid(
      type: IsolateType.network,
      inputBuffer: endpoint.writeBuffer(),
      onComplete: (data) {
        final response = utf8.decode(data!);
        onComplete(response);
      },
      onError: onError,
    ),
  );
}

void sendImageNetwork(
  Endpoint endpoint,
  void Function(List<int>) onComplete,
  void Function(dynamic, StackTrace)? onError,
) {
  final isolatePool = GetIt.instance.get<IsolatePool>();
  isolatePool.submitTask(
    Task.uuid(
      type: IsolateType.imageNetwork,
      inputBuffer: endpoint.writeBuffer(),
      onComplete: (data) {
        onComplete(data!);
      },
      onError: onError,
    ),
  );
}

void sendStreamNetwork(
  Endpoint endpoint,
  void Function(Stream<TransferableTypedData>) onStream,
) {
  final isolatePool = GetIt.instance.get<IsolatePool>();
  isolatePool.submitStream(
    StreamTask.uuid(
      type: IsolateType.network,
      inputBuffer: endpoint.writeBuffer(),
      onStream: onStream,
    ),
  );
}

void writeFile(
  String path,
  List<int> bytes,
  void Function(void) onComplete,
  void Function(dynamic, StackTrace)? onError,
) {
  final isolatePool = GetIt.instance.get<IsolatePool>();
  final fileParam = FileTaskParam(path, false, bytes);
  isolatePool.submitTask(
    Task.uuid(
      type: IsolateType.file,
      inputBuffer: fileParam.writeBuffer(),
      onComplete: (_) {
        onComplete(null);
      },
      onError: onError,
    ),
  );
}