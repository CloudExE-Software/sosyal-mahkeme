import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/theme.dart';

/// Lottie animasyon yöneticisi
class LottieAnimations {
  // Lottie dosya yolları (assets/lottie/)
  static const String success = 'assets/lottie/success.json';
  static const String error = 'assets/lottie/error.json';
  static const String loading = 'assets/lottie/loading.json';
  static const String empty = 'assets/lottie/empty.json';
  static const String celebration = 'assets/lottie/celebration.json';

  /// Başarı animasyonu göster
  static Future<void> showSuccess(
    BuildContext context, {
    String? message,
    Duration duration = const Duration(seconds: 2),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie varsa göster, yoksa emoji
              _buildAnimation(success, '✅', 120),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    await Future.delayed(duration);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Hata animasyonu göster
  static Future<void> showError(
    BuildContext context, {
    String? message,
    Duration duration = const Duration(seconds: 2),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimation(error, '❌', 120),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    await Future.delayed(duration);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Kutlama animasyonu göster
  static Future<void> showCelebration(
    BuildContext context, {
    String? message,
    Duration duration = const Duration(seconds: 3),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimation(celebration, '🎉', 150),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    await Future.delayed(duration);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Animasyon widget'ı oluştur (fallback emoji ile)
  static Widget _buildAnimation(String assetPath, String fallbackEmoji, double size) {
    return FutureBuilder(
      future: _checkAssetExists(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return Lottie.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            repeat: false,
          );
        }
        // Fallback emoji
        return Text(
          fallbackEmoji,
          style: TextStyle(fontSize: size * 0.6),
        );
      },
    );
  }

  /// Asset dosyası var mı kontrol et
  static Future<bool> _checkAssetExists(String path) async {
    try {
      await DefaultAssetBundle.of(NavigatorKey.currentContext!).load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Inline Lottie widget (ekranlarda kullanmak için)
  static Widget buildInline({
    required String assetPath,
    required String fallbackEmoji,
    double size = 100,
    bool repeat = true,
  }) {
    return FutureBuilder(
      future: _checkAssetExists(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return Lottie.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            repeat: repeat,
          );
        }
        return Text(
          fallbackEmoji,
          style: TextStyle(fontSize: size * 0.6),
        );
      },
    );
  }
}

/// Global navigator key for context access
class NavigatorKey {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  
  static BuildContext? get currentContext => key.currentContext;
}
