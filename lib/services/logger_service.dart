import 'package:flutter/foundation.dart';

/// Production-safe logger servisi
/// Debug modda console'a yazdırır, release modda sessizdir
class LoggerService {
  static const String _tag = 'HaklıKim';

  /// Bilgi mesajı (genel log)
  static void info(String message, {String? tag}) {
    _log('INFO', message, tag);
  }

  /// Hata mesajı
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag);
    if (error != null && kDebugMode) {
      debugPrint('  ↳ Error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('  ↳ Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
    }
  }

  /// Uyarı mesajı
  static void warning(String message, {String? tag}) {
    _log('WARN', message, tag);
  }

  /// Debug mesajı (sadece debug modda)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      _log('DEBUG', message, tag);
    }
  }

  static void _log(String level, String message, String? tag) {
    if (kDebugMode) {
      final tagStr = tag ?? _tag;
      debugPrint('[$level][$tagStr] $message');
    }
  }
}
