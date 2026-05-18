import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema yönetim servisi
class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  // Singleton
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

  /// Tema modunu yükle
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.dark.index;
    themeModeNotifier.value = ThemeMode.values[themeIndex];
  }

  /// Tema modunu kaydet
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    themeModeNotifier.value = mode;
  }

  /// Toggle (dark <-> light)
  Future<void> toggleTheme() async {
    final newMode = themeModeNotifier.value == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Sistem temasını kullan
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Mevcut tema dark mı?
  bool get isDark => themeModeNotifier.value == ThemeMode.dark;
  
  /// Mevcut tema light mı?
  bool get isLight => themeModeNotifier.value == ThemeMode.light;
  
  /// Sistem teması kullanılıyor mu?
  bool get isSystem => themeModeNotifier.value == ThemeMode.system;
}
