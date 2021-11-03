import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/constants.dart';
import '../external_services/local_data_src.dart';

class ThemeViewModel extends ChangeNotifier {
  final LocalDataSource _localDataSource;

  ThemeViewModel({
    required LocalDataSource localDataSource,
    ThemeMode mode = ThemeMode.system,
  })  : _localDataSource = localDataSource,
        _mode = mode;
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  //bool get isDarkMode => _mode == ThemeMode.dark;
  bool get isDarkMode => true;

  Future<void> getThemeModeFromStorage() async {
    _mode = await _localDataSource.themeMode;
    if (_mode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance!.window.platformBrightness;
      _mode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  final dark = ThemeData.dark().copyWith(
    primaryColorDark: kColorBackgroundDark,
    scaffoldBackgroundColor: kColorBackgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: kColorAccent,
      secondary: kColorAccent,
      background: kColorBackgroundDark,
      surface: kColorCardDark, // background of widgets / cards
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Colors.black87,
        onPrimary: Colors.white,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cardColor: kColorCardDark,
    //focusColor: kColorAccent,
  );

  final light = ThemeData.light().copyWith(
    primaryColorDark: kColorBackgroundLight,
    scaffoldBackgroundColor: kColorBackgroundLight,
    colorScheme: const ColorScheme.light(
      primary: kColorAccent,
      secondary: kColorAccent,
      background: kColorBackgroundLight,
      surface: kColorCardLight, // background of widgets / cards
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: kColorAccent,
        onPrimary: Colors.black87,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    //cardColor: kColorCardLight,
    //focusColor: kColorAccent,
  );

  void toggleMode() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final theme = _mode == ThemeMode.light
        ? describeEnum(ThemeMode.light)
        : describeEnum(ThemeMode.dark);
    _localDataSource.setTheme(theme);
    notifyListeners();
  }

  // ThemeData getTheme() {
  //   return _mode == ThemeViewMode.dark ? darkMode : lightMode;
  // }

}
