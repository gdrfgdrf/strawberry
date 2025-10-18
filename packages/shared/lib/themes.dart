import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

ThemeData? _themeData;

final defaultLightColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xff6750a4),
);

final defaultDarkColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xff6750a4),
  brightness: Brightness.dark,
);

void updateThemeData(ThemeData newThemeData) {
  _themeData = newThemeData;
}

ThemeData themeData() {
  if (_themeData == null) {
    throw ArgumentError("theme data is null");
  }
  return _themeData!;
}

bool isDarkMode() {
  final brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;
  return brightness == Brightness.dark;
}