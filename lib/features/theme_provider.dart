// import 'package:absensi_maps/features/theme_storage.dart';
// import 'package:flutter/material.dart';

// class ThemeProvider with ChangeNotifier { // Pastikan nama kelasnya 'ThemeProvider'
//   ThemeMode _themeMode;
//   final ThemeStorage _themeStorage;

//   ThemeProvider(this._themeStorage) : _themeMode = _themeStorage.getThemeMode();

//   ThemeMode get themeMode => _themeMode;

//   void toggleTheme() {
//     _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
//     _themeStorage.saveThemeMode(_themeMode);
//     notifyListeners();
//   }

//   void setTheme(ThemeMode mode) {
//     if (_themeMode != mode) {
//       _themeMode = mode;
//       _themeStorage.saveThemeMode(_themeMode);
//       notifyListeners();
//     }
//   }
// }