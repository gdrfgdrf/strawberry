import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:domain/result/result.dart';
import 'package:uuid/v4.dart';

import 'data_request_contracts.dart';

class BaseDataRequestManager<T> implements DataRequestManager<T> {
  final String _requestId;
  final Future<Either<Failure, T>> Function() _executor;
  final RequestConfig _config;
  final StreamController<RequestEvent> _eventController;
  final StreamController<T> _dataController;

  RequestState _state = RequestState.idle;
  RequestResult<T>? _lastResult;
  Timer? _timeoutTimer;
  int _retryCount = 0;
  bool _isDisposed = false;

  BaseDataRequestManager({
    String? requestId,
    required Future<Either<Failure, T>> Function() executor,
    RequestConfig? config,
  }) : _requestId = requestId ?? UuidV4().generate(),
        _executor = executor,
        _config = config ?? const RequestConfig(),
        _eventController = StreamController<RequestEvent>.broadcast(),
        _dataController = StreamController<T>.broadcast();

  @override
  String get requestId => _requestId;

  @override
  RequestState get state => _state;

  @override
  RequestConfig get config => _config;

  @override
  Stream<RequestEvent> get events => _eventController.stream;

  @override
  RequestResult<T>? get lastResult => _lastResult;

  @override
  Future<Either<Failure, T>> execute() async {
    if (_isDisposed) {
      return Left(Failure.current(StateError('Request manager has been disposed')));
    }

    if (_state == RequestState.pending) {
      return Left(Failure.current(StateError('Request is already in progress')));
    }

    try {
      _updateState(RequestState.pending);
      _publishEvent(RequestStarted(_requestId));

      _setupTimeout();

      final result = await _executor();

      _cancelTimeout();

      return await result.fold(
            (failure) async {
          await _handleFailure(failure);
          return Left(failure);
        },
            (data) async {
          await _handleSuccess(data);
          return Right(data);
        },
      );
    } catch (error, stackTrace) {
      _cancelTimeout();
      final failure = Failure(
        error,
        stackTrace
      );
      await _handleFailure(failure);
      return Left(failure);
    }
  }

  @override
  Stream<T> executeStream() async* {
    if (_isDisposed) {
      throw StateError('Request manager has been disposed');
    }

    await for (final event in events) {
      if (event is RequestCompleted<T>) {
        yield event.data;
      } else if (event is RequestFailed) {
        throw event.error;
      }
    }

    final result = await execute();
    yield* result.fold(
          (failure) => Stream.error(failure),
          (data) => Stream.value(data),
    );
  }

  @override
  Future<void> cancel() async {
    if (_state != RequestState.pending) return;

    _cancelTimeout();
    _updateState(RequestState.cancelled);
    _publishEvent(RequestCancelled(_requestId));

    _retryCount = 0;
  }

  @override
  Future<void> reset() async {
    await cancel();

    _lastResult = null;
    _retryCount = 0;
    _updateState(RequestState.idle);
  }

  @override
  StreamSubscription<RequestEvent> listen(
      void Function(RequestEvent) onEvent, {
        bool? cancelOnError,
      }) {
    return _eventController.stream.listen(
      onEvent,
      cancelOnError: cancelOnError,
    );
  }

  Future<void> _handleSuccess(T data) async {
    _lastResult = RequestResult(
      data: data,
      state: RequestState.completed,
      timestamp: DateTime.now(),
    );

    _updateState(RequestState.completed);
    _publishEvent(RequestCompleted<T>(_requestId, data));

    if (!_dataController.isClosed) {
      _dataController.add(data);
    }

    _retryCount = 0;
  }

  Future<void> _handleFailure(Failure failure) async {
    _lastResult = RequestResult(
      error: failure,
      state: RequestState.failed,
      timestamp: DateTime.now(),
    );

    if (_shouldRetry(failure)) {
      await _retry();
      return;
    }

    _updateState(RequestState.failed);
    _publishEvent(RequestFailed(_requestId, failure));
  }

  bool _shouldRetry(Failure failure) {
    return _retryCount < _config.maxRetries;
  }

  Future<void> _retry() async {
    _retryCount++;

    final delayMs = min(
      1000 * pow(2, _retryCount - 1),
      10000,
    ).toInt();

    await Future.delayed(Duration(milliseconds: delayMs));

    await execute();
  }

  void _setupTimeout() {
    _timeoutTimer = Timer(_config.timeout, () {
      if (_state == RequestState.pending) {
        final failure = Failure.current(TimeoutException('Request timed out after ${_config.timeout}'));
        _handleFailure(failure);
      }
    });
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void _updateState(RequestState state) {
    _state = state;
  }

  void _publishEvent(RequestEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    await cancel();

    await Future.wait([
      _eventController.close(),
      _dataController.close(),
    ]);
  }
}

class BatchRequestManagerImpl implements BatchRequestManager {
  final int _maxConcurrency;

  BatchRequestManagerImpl({int maxConcurrency = 5})
      : _maxConcurrency = maxConcurrency;

  @override
  Future<List<Either<Failure, dynamic>>> executeBatch(
      List<DataRequestManager> requests,
      ) async {
    return executeParallel(requests);
  }

  @override
  Future<List<Either<Failure, dynamic>>> executeParallel(
      List<DataRequestManager> requests,
      ) async {
    if (requests.isEmpty) return [];

    final results = List<Either<Failure, dynamic>>.filled(
      requests.length,
      Left(Failure.current(StateError('Not executed'))),
    );

    final semaphore = _Semaphore(_maxConcurrency);
    final futures = <Future<void>>[];

    for (var i = 0; i < requests.length; i++) {
      futures.add(
        semaphore.run(() async {
          try {
            final result = await requests[i].execute();
            results[i] = result;
          } catch (error, stackTrace) {
            results[i] = Left(Failure(error, stackTrace));
          }
        }),
      );
    }

    await Future.wait(futures);
    return results;
  }

  @override
  Future<List<Either<Failure, dynamic>>> executeSequential(
      List<DataRequestManager> requests,
      ) async {
    final results = <Either<Failure, dynamic>>[];

    for (final request in requests) {
      try {
        final result = await request.execute();
        results.add(result);

        if (result.isLeft()) {
          break;
        }
      } catch (error, stackTrace) {
        results.add(Left(Failure(
          error, stackTrace
        )));
      }
    }

    return results;
  }
}

class RequestQueueManagerImpl implements RequestQueueManager {
  final List<DataRequestManager> _queue = [];
  bool _isProcessing = false;
  final StreamController<void> _processingController = StreamController<void>.broadcast();

  @override
  int get queueSize => _queue.length;

  @override
  bool get isProcessing => _isProcessing;

  @override
  Future<void> enqueue<T>(DataRequestManager<T> request) async {
    _queue.add(request);

    if (!_isProcessing) {
      await process();
    }
  }

  @override
  Future<void> dequeue(String requestId) async {
    _queue.removeWhere((request) => request.requestId == requestId);
  }

  @override
  Future<void> process() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;
    _processingController.add(null);

    try {
      while (_queue.isNotEmpty) {
        final request = _queue.removeAt(0);

        try {
          await request.execute();
        } catch (error) {
          print('Error processing request ${request.requestId}: $error');
        }

        await Future.delayed(Duration.zero);
      }
    } finally {
      _isProcessing = false;
      _processingController.add(null);
    }
  }

  @override
  Future<void> clear() async {
    for (final request in _queue) {
      await request.cancel();
    }

    _queue.clear();
  }

  Future<void> dispose() async {
    await clear();
    await _processingController.close();
  }
}

class RequestFactoryImpl implements RequestFactory {
  @override
  DataRequestManager<T> createRequest<T>(
      String requestId,
      Future<Either<Failure, T>> Function() executor, {
        RequestConfig? config,
      }) {
    return BaseDataRequestManager<T>(
      requestId: requestId,
      executor: executor,
      config: config,
    );
  }
}

class _Semaphore {
  final int _maxCount;
  int _currentCount = 0;
  final _queue = <Completer<void>>[];

  _Semaphore(this._maxCount);

  Future<void> acquire() async {
    if (_currentCount < _maxCount) {
      _currentCount++;
      return;
    }

    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
  }

  void release() {
    _currentCount--;

    if (_queue.isNotEmpty) {
      final completer = _queue.removeAt(0);
      _currentCount++;
      completer.complete();
    }
  }

  Future<R> run<R>(Future<R> Function() action) async {
    await acquire();
    try {
      return await action();
    } finally {
      release();
    }
  }
}