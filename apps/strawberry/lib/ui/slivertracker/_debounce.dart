
import 'dart:async';

/// 此处将 int t = 30 修改为了 Duration
Function debounce(Function fn, [Duration duration = const Duration(milliseconds: 30)]) {
  Timer? _debounce;
  return () {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(duration, () {
      fn();
    });

    return _debounce;

  };
}