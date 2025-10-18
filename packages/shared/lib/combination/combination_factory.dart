import 'package:flutter/foundation.dart';

import 'combined.dart';

class CombinedNotifierFactory {
  static CombinedNotifier<(T1, T2)> combine2<T1, T2>(
    ValueListenable<T1> notifier1,
    ValueListenable<T2> notifier2,
  ) {
    return CombinedNotifier<(T1, T2)>([
      notifier1,
      notifier2,
    ], (values) => (values[0] as T1, values[1] as T2));
  }

  static CombinedNotifier<(T1, T2, T3)> combine3<T1, T2, T3>(
    ValueListenable<T1> notifier1,
    ValueListenable<T2> notifier2,
    ValueListenable<T3> notifier3,
  ) {
    return CombinedNotifier<(T1, T2, T3)>([
      notifier1,
      notifier2,
      notifier3,
    ], (values) => (values[0] as T1, values[1] as T2, values[2] as T3));
  }
}
