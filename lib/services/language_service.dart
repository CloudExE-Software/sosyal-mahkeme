import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app language
class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  static const String _keyLanguage = 'app_language';
  
  Locale _currentLocale = const Locale('tr');
  
  Locale get currentLocale => _currentLocale;

  /// Initialize language service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_keyLanguage) ?? 'tr';
    _currentLocale = Locale(languageCode);
  }

  /// Change app language
  Future<void> setLanguage(Locale locale) async {
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, locale.languageCode);
  }

  /// Get language name
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return languageCode;
    }
  }

  /// Get supported locales
  List<Locale> getSupportedLocales() {
    return const [
      Locale('tr'),
      Locale('en'),
      Locale('ar'),
    ];
  }
}
