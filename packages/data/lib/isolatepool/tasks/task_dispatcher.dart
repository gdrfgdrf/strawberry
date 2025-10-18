import 'dart:isolate';
import 'dart:typed_data';

import '../../http/url/api_url_provider.dart';
import '../isolate_pool_bean.dart';
import 'file_task_impl.dart';
import 'network_task_impl.dart';

void dispatchStreamTask(String id, IsolateType type, Uint8List? buffer, SendPort sendPort) {
  switch (type) {
    case IsolateType.network:
      final endpoint = Endpoint.readBuffer(buffer!);
      processStreamNetworkTask(id, endpoint, sendPort);
    case IsolateType.imageNetwork:
      final endpoint = Endpoint.readBuffer(buffer!);
      processStreamNetworkTask(id, endpoint, sendPort);
    case IsolateType.file:
      final param = FileTaskParam.readBuffer(buffer!);
      processStreamFileTask(id, param, sendPort);
  }
}

Future<Uint8List?> dispatchTask(String id, IsolateType type, Uint8List? buffer) {
  switch (type) {
    case IsolateType.network:
      final endpoint = Endpoint.readBuffer(buffer!);
      return processNetworkTask(id, endpoint);

    case IsolateType.imageNetwork:
      final endpoint = Endpoint.readBuffer(buffer!);
      return processNetworkTask(id, endpoint);

    case IsolateType.file:
      final param = FileTaskParam.readBuffer(buffer!);
      return processFileTask(id, param);
  }
}
