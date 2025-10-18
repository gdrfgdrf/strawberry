import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:natives/ffi/atomic.dart';
import 'package:uuid/uuid.dart';

typedef DataReceiver = void Function(Uint8List? data);
typedef ErrorReceiver = void Function(dynamic error, StackTrace);

typedef StreamDataReceiver = void Function(Stream<TransferableTypedData> dataStream);

/// 运行时会将所有 portion 相加得到 total
/// 之后每种 type 的实际 Isolate 数量将根据
/// CPU 核心数 * portion / total 算出，结果四舍五入
/// 若算出的值不足 1，结果取 1
enum IsolateType {
  network(12, 3, 12),
  imageNetwork(6, 3, 12),
  file(4, 1, 4);

  final int portion;
  final int min;
  final int max;

  const IsolateType(this.portion, this.min, this.max);
}

class StreamTask {
  final String id;
  final IsolateType type;
  final Duration timeout;
  final Uint8List? inputBuffer;
  final StreamDataReceiver? onStream;

  StreamTask({
    required this.id,
    required this.type,
    this.timeout = const Duration(minutes: 1),
    this.inputBuffer,
    this.onStream,
  });

  void provideStream(Stream<TransferableTypedData> stream) {
    onStream?.call(stream);
  }

  static StreamTask uuid({
    required IsolateType type,
    Duration timeout = const Duration(minutes: 1),
    Uint8List? inputBuffer,
    StreamDataReceiver? onStream,
  }) {
    return StreamTask(
      id: Uuid().v4(),
      type: type,
      timeout: timeout,
      inputBuffer: inputBuffer,
      onStream: onStream,
    );
  }
}

class Task {
  final String id;
  final IsolateType type;
  final Duration timeout;
  final Uint8List? inputBuffer;
  final DataReceiver? onComplete;
  final ErrorReceiver? onError;

  Task({
    required this.id,
    required this.type,
    this.timeout = const Duration(minutes: 1),
    this.inputBuffer,
    this.onComplete,
    this.onError,
  });

  static Task uuid({
    required IsolateType type,
    Duration timeout = const Duration(minutes: 1),
    Uint8List? inputBuffer,
    DataReceiver? onComplete,
    ErrorReceiver? onError,
  }) {
    return Task(
      id: Uuid().v4(),
      type: type,
      timeout: timeout,
      inputBuffer: inputBuffer,
      onComplete: onComplete,
      onError: onError,
    );
  }
}

class IsolateWorker {
  final IsolateType type;
  final String name;
  final SendPort sendPort;
  final ReceivePort receivePort;

  AtomicCounter taskCount = AtomicApi.createCounter(initial: 0);
  bool isIdle;

  IsolateWorker({
    required this.type,
    required this.name,
    required this.isIdle,
    required this.sendPort,
    required this.receivePort,
  });

  void taskSubmitted() {
    if (taskCount.increment() >= 2) {
      isIdle = false;
    }
  }

  void taskFinished() {
    if (taskCount.decrement() < 2) {
      isIdle = true;
    }
  }
}

abstract class Actions {
  static int isolateReady = 0;
  static int init = 1;
  static int isolateInitialized = 2;

  static int submitTask = 3;
  static int isolateTaskFinished = 4;
  static int isolateTaskError = 5;

  static int submitStreamTask = 6;
  static int isolateStreamProviderFinished = 7;

  static int shutdown = 8;
}

class Action {
  final int type;
  final dynamic content;

  const Action(this.type, {this.content});
}

class SubmitStreamAction extends Action {
  final String id;
  final TransferableTypedData? buffer;
  final SendPort sendPort;

  const SubmitStreamAction(
    super.type,
    this.id,
    this.sendPort, {
    this.buffer,
    super.content,
  });
}

class SubmitAction extends Action {
  final String id;
  final TransferableTypedData? buffer;

  const SubmitAction(super.type, this.id, {this.buffer, super.content});
}

class StreamResultAction extends Action {
  final String id;

  final IsolateType isolateType;
  final String isolateName;

  const StreamResultAction(
    super.type,
    this.id,
    this.isolateType,
    this.isolateName,
  );
}

class ResultAction extends Action {
  final String id;
  final TransferableTypedData? buffer;

  final IsolateType isolateType;
  final String isolateName;

  const ResultAction(
    super.type,
    this.id,
    this.buffer,
    this.isolateType,
    this.isolateName, {
    super.content,
  });
}

class ErrorAction extends Action {
  final String id;
  final dynamic error;
  final StackTrace stackTrace;

  final IsolateType isolateType;
  final String isolateName;

  const ErrorAction(
    super.type,
    this.id,
    this.error,
    this.stackTrace,
    this.isolateType,
    this.isolateName, {
    super.content,
  });
}

extension ActionIntFactory on int {
  Action createAction({dynamic content}) {
    return Action(this, content: content);
  }

  SubmitStreamAction submitStreamAction(
    String id,
    SendPort sendPort, {
    TransferableTypedData? buffer,
    dynamic content,
  }) {
    return SubmitStreamAction(
      this,
      id,
      sendPort,
      buffer: buffer,
      content: content,
    );
  }

  SubmitAction submitAction(
    String id, {
    TransferableTypedData? buffer,
    dynamic content,
  }) {
    return SubmitAction(this, id, buffer: buffer, content: content);
  }

  StreamResultAction streamResultAction(
    String id,
    IsolateType isolateType,
    String isolateName,
  ) {
    return StreamResultAction(this, id, isolateType, isolateName);
  }

  ResultAction resultAction(
    String id,
    TransferableTypedData? result,
    IsolateType isolateType,
    String isolateName, {
    dynamic content,
  }) {
    return ResultAction(
      this,
      id,
      result,
      isolateType,
      isolateName,
      content: content,
    );
  }

  ErrorAction errorAction(
    String id,
    dynamic error,
    StackTrace stackTrace,
    IsolateType isolateType,
    String isolateName, {
    dynamic content,
  }) {
    return ErrorAction(
      this,
      id,
      error,
      stackTrace,
      isolateType,
      isolateName,
      content: content,
    );
  }
}

class BufferReader {
  final ByteData _data;
  int _offset = 0;

  BufferReader(Uint8List? bytes)
    : _data = bytes != null ? ByteData.sublistView(bytes) : ByteData(0);

  T readEnum<T extends Enum>(List<T> values) {
    final ordinary = readInt();
    return values[ordinary];
  }

  bool readBool() {
    return readInt() == 0;
  }

  bool? readNullableBool() {
    final i = readInt();
    if (i <= -1) {
      return null;
    }
    return i == 0;
  }

  int readInt() {
    final value = _data.getInt32(_offset);
    _offset += 4;
    return value;
  }

  int? readNullableInt() {
    final flag = readInt();
    if (flag <= -1) {
      return null;
    }
    return readInt();
  }

  double readDouble() {
    final value = _data.getFloat64(_offset);
    _offset += 8;
    return value;
  }

  String readString() {
    final length = readInt();
    final bytes = Uint8List.sublistView(_data, _offset, _offset + length);
    _offset += length;
    return String.fromCharCodes(bytes);
  }

  String? readNullableString() {
    final flag = readInt();
    if (flag <= -1) {
      return null;
    }
    final length = readInt();
    final bytes = Uint8List.sublistView(_data, _offset, _offset + length);
    _offset += length;
    return String.fromCharCodes(bytes);
  }

  dynamic readJson() {
    final string = readString();
    return jsonDecode(string);
  }

  dynamic readNullableJson() {
    final i = readInt();
    if (i <= -1) {
      return null;
    }
    final string = readString();
    return jsonDecode(string);
  }

  Uint8List readBytes() {
    final length = readInt();
    return readRawBytes(length);
  }

  Uint8List? readNullableBytes() {
    final flag = readInt();
    if (flag <= -1) {
      return null;
    }
    return readBytes();
  }

  Uint8List readRawBytes(int length) {
    final bytes = Uint8List.sublistView(_data, _offset, _offset + length);
    _offset += length;
    return bytes;
  }

  Uint8List? readNullableRawBytes(int length) {
    final flag = readInt();
    if (flag <= -1) {
      return null;
    }
    return readRawBytes(length);
  }
}

class BufferWriter {
  final _buffer = BytesBuilder();
  ByteData _writer = ByteData(1024);
  int _offset = 0;

  void _ensureCapacity(int bytes) {
    if (_offset + bytes > _writer.lengthInBytes) {
      _buffer.add(_writer.buffer.asUint8List(0, _offset));
      final newSize = (_offset + bytes) * 2;
      _writer = ByteData(newSize);
      _offset = 0;
    }
  }

  void writeEnum(Enum value) {
    writeInt(value.index);
  }

  void writeBool(bool value) {
    writeInt(value ? 0 : 1);
  }

  void writeNullableBool(bool? value) {
    if (value == null) {
      writeInt(-1);
      return;
    }
    writeInt(value ? 0 : 1);
  }

  void writeInt(int value) {
    _ensureCapacity(4);
    _writer.setInt32(_offset, value);
    _offset += 4;
  }

  void writeNullableInt(int? value) {
    if (value == null) {
      writeInt(-1);
      return;
    }
    writeInt(0);
    writeInt(value);
  }

  void writeDouble(double value) {
    _ensureCapacity(8);
    _writer.setFloat64(_offset, value);
    _offset += 8;
  }

  void writeString(String value) {
    final bytes = Uint8List.fromList(value.codeUnits);
    writeInt(bytes.length);

    if (_offset > 0) {
      _buffer.add(_writer.buffer.asUint8List(0, _offset));
      _offset = 0;
    }

    _buffer.add(bytes);
  }

  void writeNullableString(String? value) {
    if (value == null) {
      writeInt(-1);
      return;
    }
    writeInt(0);
    writeString(value);
  }

  void writeJson(dynamic json) {
    writeString(jsonEncode(json));
  }

  void writeNullableJson(dynamic json) {
    if (json == null) {
      writeInt(-1);
      return;
    }
    writeInt(0);
    writeString(jsonEncode(json));
  }

  void writeBytes(Uint8List bytes) {
    writeInt(bytes.length);
    writeRawBytes(bytes);
  }

  void writeNullableBytes(Uint8List? bytes) {
    if (bytes == null) {
      writeInt(-1);
      return;
    }
    writeInt(0);
    writeBytes(bytes);
  }

  void writeRawBytes(Uint8List bytes) {
    if (_offset > 0) {
      _buffer.add(_writer.buffer.asUint8List(0, _offset));
      _offset = 0;
    }
    _buffer.add(bytes);
  }

  void writeNullableRawBytes(Uint8List? bytes) {
    if (bytes == null) {
      writeInt(-1);
      return;
    }
    writeInt(0);
    writeRawBytes(bytes);
  }

  Uint8List takeBytes() {
    if (_offset > 0) {
      _buffer.add(_writer.buffer.asUint8List(0, _offset));
      _offset = 0;
    }
    return _buffer.takeBytes();
  }
}
