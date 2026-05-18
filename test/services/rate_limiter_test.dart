import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanal_mahkeme/services/rate_limiter.dart';
import 'package:sanal_mahkeme/utils/error_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock'u bir kez başlat - singleton _prefs bu instance'ı kullanacak
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Her test arasında state'i temizle
  setUp(() async {
    final rateLimiter = RateLimiter();
    await rateLimiter.reset();
  });

  group('RateLimiter', () {
    test('ilk istek her zaman izin verilir', () async {
      final rateLimiter = RateLimiter();
      final canRequest = await rateLimiter.canMakeRequest();
      expect(canRequest, isTrue);
    });

    test('istek kaydedildikten sonra cooldown aktif olur', () async {
      final rateLimiter = RateLimiter();
      await rateLimiter.recordRequest();
      final canRequest = await rateLimiter.canMakeRequest();
      expect(canRequest, isFalse);
    });

    test('checkRateLimit izin vermezse RateLimitException firlatir', () async {
      final rateLimiter = RateLimiter();
      await rateLimiter.recordRequest();
      expect(() => rateLimiter.checkRateLimit(), throwsA(isA<RateLimitException>()));
    });

    test('checkRateLimit ilk istekte hata firlatmaz', () async {
      final rateLimiter = RateLimiter();
      await rateLimiter.checkRateLimit();
    });

    test('toplam istek sayisi dogru sayilir', () async {
      final rateLimiter = RateLimiter();
      await rateLimiter.recordRequest();
      await rateLimiter.recordRequest();
      await rateLimiter.recordRequest();

      final total = await rateLimiter.getTotalRequests();
      expect(total, 3);
    });

    test('reset tum istatistikleri sifirlar', () async {
      final rateLimiter = RateLimiter();
      await rateLimiter.recordRequest();
      await rateLimiter.recordRequest();
      await rateLimiter.reset();

      final canRequest = await rateLimiter.canMakeRequest();
      final totalRequests = await rateLimiter.getTotalRequests();

      expect(canRequest, isTrue);
      expect(totalRequests, 0);
    });

    test('hic istek yoksa kalan sure 0', () async {
      final rateLimiter = RateLimiter();
      final remaining = await rateLimiter.getRemainingCooldown();
      expect(remaining, 0);
    });
  });
}
