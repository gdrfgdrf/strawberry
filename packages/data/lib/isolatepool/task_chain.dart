import 'dart:typed_data';

import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/isolate_pool_extensions.dart';

class TaskWrapper<T> {
  final AbstractTask<T> task;

  dynamic Function(dynamic result, dynamic previousResult)? onComplete;
  void Function(dynamic, StackTrace)? onError;

  TaskWrapper(this.task, {this.onComplete, this.onError});

  void run({
    void Function(T result)? onComplete,
    void Function(dynamic, StackTrace)? onError,
  }) {
    task.run(
      (result) {
        onComplete?.call(result);
      },
      (e, s) {
        onError?.call(e, s);
      },
    );
  }
}

abstract class AbstractTask<T> {
  void run(
    void Function(T result) onComplete,
    void Function(dynamic, StackTrace)? onError,
  );
}

abstract class AbstractStreamTask {
  void run(void Function(Stream<Uint8List>) onStream);
}

class TaskContext {
  final dynamic previousValue;
  final dynamic previousOnCompleteValue;
  final int currentWrapper;

  TaskContext(
    this.previousValue,
    this.previousOnCompleteValue,
    this.currentWrapper,
  );
}

class TaskChain {
  final List<TaskWrapper> _wrappers = [];
  TaskWrapper? _currentWrapper;

  /// 任务的onComplete执行完成后会变
  TaskContext? currentContext;
  void Function()? _globalOnComplete;
  void Function(int, dynamic, StackTrace)? _globalOnError;

  TaskChain network(Endpoint Function() endpoint) {
    wrapper(TaskWrapper(_BinaryNetworkTask(endpoint)));
    return this;
  }

  TaskChain stringNetwork(Endpoint Function() endpoint) {
    wrapper(TaskWrapper(_StringNetworkTask(endpoint)));
    return this;
  }

  TaskChain imageNetwork(Endpoint Function() endpoint) {
    wrapper(TaskWrapper(_ImageNetworkTask(endpoint)));
    return this;
  }

  // TaskChain readFile(String Function() path) {
  //   wrapper(TaskWrapper(_ReadFileTask(path)));
  //   return this;
  // }

  TaskChain writeFile(String Function() path, List<int> Function() bytes) {
    wrapper(TaskWrapper(_WriteFileTask(path, bytes)));
    return this;
  }

  TaskChain wrapper<T>(TaskWrapper<T> wrapper) {
    if (_currentWrapper != null) {
      _wrappers.add(_currentWrapper!);
      _currentWrapper = null;
    }
    _currentWrapper = wrapper;
    return this;
  }

  TaskChain onComplete(
    dynamic Function(dynamic result, dynamic previousResult) onComplete,
  ) {
    _currentWrapper?.onComplete = onComplete;
    return this;
  }

  TaskChain onError(void Function(dynamic, StackTrace) onError) {
    _currentWrapper?.onError = onError;
    return this;
  }

  TaskChain globalOnComplete(void Function() onComplete) {
    _globalOnComplete = onComplete;
    return this;
  }

  TaskChain globalOnError(void Function(int, dynamic, StackTrace) onError) {
    _globalOnError = onError;
    return this;
  }

  TaskChain allInOne<T>(
    AbstractTask<T> task, {
    dynamic Function(T result, dynamic previousResult)? onComplete,
    void Function(dynamic, StackTrace)? onError,
  }) {
    final wrapper = TaskWrapper<T>(
      task,
      onComplete:
          onComplete as Function(dynamic result, dynamic previousResult)?,
      onError: onError,
    );
    _wrappers.add(wrapper);
    return this;
  }

  void run() {
    if (_currentWrapper != null) {
      _wrappers.add(_currentWrapper!);
      _currentWrapper = null;
    }
    _internalRun(null, null, 0);
    return;
  }

  void _internalRun(
    dynamic previousValue,
    dynamic previousOnCompleteValue,
    int currentWrapper,
  ) {
    currentContext = TaskContext(
      previousValue,
      previousOnCompleteValue,
      currentWrapper,
    );

    if (currentWrapper >= _wrappers.length) {
      _globalOnComplete?.call();
      return;
    }

    final wrapper = _wrappers[currentWrapper];
    wrapper.run(
      onComplete: (result) {
        final onCompleteValue = wrapper.onComplete?.call(result, previousValue);
        if (onCompleteValue is Future) {
          onCompleteValue.then(
            (value) {
              _internalRun(result, value, currentWrapper + 1);
            },
            onError: (e) {
              wrapper.onError?.call(e, StackTrace.current);
              _globalOnError?.call(currentWrapper, e, StackTrace.current);
            },
          );
          return;
        }

        _internalRun(result, onCompleteValue, currentWrapper + 1);
      },
      onError: (e, s) {
        wrapper.onError?.call(e, s);
        _globalOnError?.call(currentWrapper, e, s);
      },
    );
  }
}

class _BinaryNetworkTask extends AbstractTask<List<int>> {
  final Endpoint Function() endpoint;

  _BinaryNetworkTask(this.endpoint) : super();

  @override
  void run(
    void Function(List<int> result) onComplete,
    void Function(dynamic, StackTrace)? onError,
  ) {
    sendBinaryNetwork(endpoint(), onComplete, onError);
  }
}

class _StringNetworkTask extends AbstractTask<String> {
  final Endpoint Function() endpoint;

  _StringNetworkTask(this.endpoint) : super();

  @override
  void run(
    void Function(String result) onComplete,
    void Function(dynamic, StackTrace)? onError,
  ) {
    sendStringNetwork(endpoint(), onComplete, onError);
  }
}

class _ImageNetworkTask extends AbstractTask<List<int>> {
  final Endpoint Function() endpoint;

  _ImageNetworkTask(this.endpoint) : super();

  @override
  void run(void Function(List<int> result) onComplete, void Function(dynamic p1, StackTrace p2)? onError) {
    sendImageNetwork(endpoint(), onComplete, onError);
  }
}

// class _ReadFileTask extends AbstractTask<List<int>> {
//   final String Function() path;
//
//   _ReadFileTask(this.path) : super();
//
//   @override
//   void run(
//     void Function(List<int> result) onComplete,
//     void Function(dynamic, StackTrace)? onError,
//   ) {
//     readFile(path(), onComplete, onError);
//   }
// }

class _WriteFileTask extends AbstractTask {
  final String Function() path;
  final List<int> Function() bytes;

  _WriteFileTask(this.path, this.bytes) : super();

  @override
  void run(
    void Function(void) onComplete,
    void Function(dynamic, StackTrace)? onError,
  ) {
    writeFile(path(), bytes(), onComplete, onError);
  }
}