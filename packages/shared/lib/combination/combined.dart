import 'package:flutter/foundation.dart';

class Combined<T> {
  final T values;

  const Combined(this.values);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Combined<T> && values == other.values;
  }

  @override
  int get hashCode => values.hashCode;
}

class CombinedNotifier<T> extends ValueNotifier<Combined<T>> {
  final List<ValueListenable> _notifiers;
  final T Function(List<dynamic>) _combiner;

  CombinedNotifier(this._notifiers, this._combiner)
    : super(Combined<T>(_combiner(_notifiers.map((n) => n.value).toList()))) {
    for (var notifier in _notifiers) {
      notifier.addListener(_updateValue);
    }
  }

  void _updateValue() {
    value = Combined<T>(_combiner(_notifiers.map((n) => n.value).toList()));
  }

  @override
  void dispose() {
    for (var notifier in _notifiers) {
      notifier.removeListener(_updateValue);
    }
    super.dispose();
  }
}
