import 'dart:async';
import 'dart:isolate';

import 'package:domain/result/result.dart';

class StreamProvider {
  final ReceivePort receivePort;

  const StreamProvider(this.receivePort);

  void listen(
    StreamController<TransferableTypedData> controller, {
    void Function(StreamEndSignal)? onClose,
  }) {
    receivePort.listen((data) {
      if (data is StreamEndSignal) {
        if (data.failure != null) {
          controller.addError(data.failure!.error, data.failure!.stackTrace);
        }

        controller.close();
        receivePort.close();
        onClose?.call(data);
        return;
      }
      controller.add(data);
    });
  }
}

class StreamEndSignal {
  final Failure? failure;

  const StreamEndSignal(this.failure);

}
