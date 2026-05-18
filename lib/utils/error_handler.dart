import 'package:flutter/material.dart';

/// Özel hata tipleri
class AppException implements Exception {
  final String message;
  final String userMessage;

  AppException(this.message, this.userMessage);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException()
      : super(
          'Network error',
          'İnternet bağlantınızı kontrol edin.',
        );
}

class APIException extends AppException {
  APIException(String message)
      : super(
          'API error: $message',
          'Sunucuda bir sorun oluştu. Lütfen daha sonra tekrar deneyin.',
        );
}

class RateLimitException extends AppException {
  final int remainingSeconds;

  RateLimitException(this.remainingSeconds)
      : super(
          'Rate limit exceeded',
          'Çok fazla istek gönderdiniz. $remainingSeconds saniye sonra tekrar deneyin.',
        );
}

class InvalidInputException extends AppException {
  InvalidInputException(String reason)
      : super(
          'Invalid input: $reason',
          'Lütfen geçerli bir metin girin.',
        );
}

/// Hata yönetimi yardımcı sınıfı
class ErrorHandler {
  /// Hatayı kullanıcı dostu mesaja çevir
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return error.userMessage;
    }

    if (error is FormatException) {
      return 'Veri formatı hatalı. Lütfen tekrar deneyin.';
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'İnternet bağlantınızı kontrol edin.';
    }

    if (errorString.contains('timeout')) {
      return 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'API anahtarınız geçersiz. Lütfen ayarlardan kontrol edin.';
    }

    if (errorString.contains('429') || errorString.contains('rate limit')) {
      return 'API limit aşıldı. Lütfen biraz bekleyin.';
    }

    if (errorString.contains('500') || errorString.contains('server')) {
      return 'Sunucuda bir sorun oluştu. Lütfen daha sonra tekrar deneyin.';
    }

    // Genel hata
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }

  /// Hata dialog göster
  static void showErrorDialog(BuildContext context, dynamic error) {
    final message = getUserMessage(error);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Hata'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Hata snackbar göster
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    final message = getUserMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Kapat',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Hatayı logla (production'da Firebase Crashlytics'e gönderilir)
  static void logError(dynamic error, StackTrace? stackTrace) {
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
    
    // TODO: Firebase Crashlytics'e gönder
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
