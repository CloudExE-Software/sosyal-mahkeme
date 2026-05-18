import 'package:shared_preferences/shared_preferences.dart';
import '../utils/error_handler.dart';

/// Rate limiting servisi - Spam önleme
class RateLimiter {
  static final RateLimiter _instance = RateLimiter._internal();
  factory RateLimiter() => _instance;
  RateLimiter._internal();

  static const String _lastRequestKey = 'last_request_time';
  static const String _requestCountKey = 'request_count';
  static const int _cooldownSeconds = 30; // 30 saniye bekleme

  SharedPreferences? _prefs;

  /// Initialize
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// İstek yapılabilir mi kontrol et
  Future<bool> canMakeRequest() async {
    await init();

    final lastRequestTime = _prefs?.getInt(_lastRequestKey);
    if (lastRequestTime == null) {
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - lastRequestTime;
    final secondsPassed = difference ~/ 1000;

    return secondsPassed >= _cooldownSeconds;
  }

  /// Kalan bekleme süresini döndür (saniye)
  Future<int> getRemainingCooldown() async {
    await init();

    final lastRequestTime = _prefs?.getInt(_lastRequestKey);
    if (lastRequestTime == null) {
      return 0;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - lastRequestTime;
    final secondsPassed = difference ~/ 1000;

    if (secondsPassed >= _cooldownSeconds) {
      return 0;
    }

    return _cooldownSeconds - secondsPassed;
  }

  /// İstek yapıldığını kaydet
  Future<void> recordRequest() async {
    await init();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs?.setInt(_lastRequestKey, now);

    // İstek sayısını artır
    final count = (_prefs?.getInt(_requestCountKey) ?? 0) + 1;
    await _prefs?.setInt(_requestCountKey, count);
  }

  /// Rate limit kontrolü yap ve hata fırlat
  Future<void> checkRateLimit() async {
    final canRequest = await canMakeRequest();
    
    if (!canRequest) {
      final remaining = await getRemainingCooldown();
      throw RateLimitException(remaining);
    }
  }

  /// İstatistikleri sıfırla
  Future<void> reset() async {
    await init();
    await _prefs?.remove(_lastRequestKey);
    await _prefs?.remove(_requestCountKey);
  }

  /// Toplam istek sayısını getir
  Future<int> getTotalRequests() async {
    await init();
    return _prefs?.getInt(_requestCountKey) ?? 0;
  }
}
