import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:data/isolatepool/isolate_executor.dart';
import 'package:data/isolatepool/stream/task_stream.dart';
import 'package:domain/result/result.dart';
import 'package:natives/wrap/fastfile_wrapper.dart';

import '../isolate_pool_bean.dart';

class FileTaskParam {
  final String path;
  final bool isRead;
  final List<int>? writeBytes;

  const FileTaskParam(this.path, this.isRead, this.writeBytes);

  static FileTaskParam readBuffer(Uint8List buffer) {
    final reader = BufferReader(buffer);

    final path = reader.readString();
    final isRead = reader.readBool();
    final writeBytes = reader.readNullableBytes();

    return FileTaskParam(path, isRead, writeBytes);
  }

  Uint8List writeBuffer() {
    final writer = BufferWriter();
    writer.writeString(path);
    writer.writeBool(isRead);
    writer.writeNullableBytes(
      writeBytes != null ? Uint8List.fromList(writeBytes!) : null,
    );
    return writer.takeBytes();
  }
}

void processStreamFileTask(String id, FileTaskParam param, SendPort sendPort) {
  logger!.trace(
    "processing a stream file task, is read: ${param.isRead}, path: ${param.path}, id: $id",
  );

  final file = File(param.path);
  if (param.isRead && !file.existsSync()) {
    throw ArgumentError("the specified file is not exists");
  }

  if (param.isRead) {
    final stream = file.openRead();
    stream.listen(
      (data) {
        sendPort.send(TransferableTypedData.fromList([Uint8List.fromList(data)]));
      },
      onDone: () {
        sendPort.send(StreamEndSignal(null));
      },
      onError: (e, s) {
        sendPort.send(StreamEndSignal(Failure(e, s)));
      },
    );
  } else {
    if (param.writeBytes == null) {
      throw ArgumentError("the isRead is false, but writeBytes is null");
    }

    file
        .writeAsBytes(param.writeBytes!, flush: true)
        .then((_) {
          sendPort.send(StreamEndSignal(null));
        })
        .onError((e, s) {
          sendPort.send(StreamEndSignal(Failure(e, s)));
        });
  }
}

Future<Uint8List?> processFileTask(String id, FileTaskParam param) async {
  logger!.trace(
    "processing a file task, is read: ${param.isRead}, path: ${param.path}, id: $id",
  );

  final file = File(param.path);
  if (param.isRead && !file.existsSync()) {
    throw ArgumentError("the specified file is not exists");
  }

  if (param.isRead) {
    final fastFile = DartFastFile(param.path);

    fastFile.open();
    final result = fastFile.copy();

    return result;
  } else {
    if (param.writeBytes == null) {
      throw ArgumentError("the isRead is false, but writeBytes is null");
    }
    final completer = Completer<Uint8List?>();

    file
        .writeAsBytes(param.writeBytes!, flush: true)
        .then((_) {
          completer.complete(null);
        })
        .onError((e, s) {
          completer.completeError(e ?? ArgumentError("exception is null"), s);
        });
    return completer.future;
  }
}
