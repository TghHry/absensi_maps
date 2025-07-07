import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeStorage { // Pastikan nama kelasnya 'ThemeStorage'
  static const String _themeModeKey = 'theme_mode';
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  ThemeStorage(this._sharedPreferences, this._secureStorage);

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _sharedPreferences.setString(_themeModeKey, themeMode.toString());
  }

  ThemeMode getThemeMode() {
    final String? themeModeString = _sharedPreferences.getString(_themeModeKey);
    if (themeModeString == ThemeMode.dark.toString()) {
      return ThemeMode.dark;
    } else if (themeModeString == ThemeMode.light.toString()) {
      return ThemeMode.light;
    }
    return ThemeMode.system; // Default
  }
}