import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:natives/wrap/strawberry_logger_wrapper.dart';

abstract class StrawberryBloc<Event, State> extends Bloc<Event, State> {
  DartStrawberryServiceLogger? serviceLogger;

  StrawberryBloc(super.initialState) {
    serviceLogger = openService("BlocService-$runtimeType");
    serviceLogger!.info("creating: $hashCode");
  }

  @override
  void on<E extends Event>(
    EventHandler<E, State> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>((event, emit) {
      serviceLogger!.trace("on: ${event.runtimeType}: $hashCode");
      return handler(
        event,
        ForwardingEmitter<State>(emit, (state) {
          serviceLogger!.trace("emitting: ${state.runtimeType}: $hashCode");
        }),
      );
    }, transformer: transformer);
  }

  @override
  Future<void> close() {
    serviceLogger!.info("closing: $hashCode");
    return super.close();
  }
}

class ForwardingEmitter<State> extends Emitter<State> {
  final void Function(State)? beforeCall;
  final Emitter<State> output;

  ForwardingEmitter(this.output, this.beforeCall);

  @override
  void call(State state) {
    beforeCall?.call(state);
    output.call(state);
  }

  @override
  Future<void> forEach<T>(
    Stream<T> stream, {
    required State Function(T data) onData,
    State Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return output.forEach(stream, onData: onData, onError: onError);
  }

  @override
  bool get isDone => output.isDone;

  @override
  Future<void> onEach<T>(
    Stream<T> stream, {
    required void Function(T data) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return output.onEach(stream, onData: onData, onError: onError);
  }
}
