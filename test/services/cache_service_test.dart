import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanal_mahkeme/services/cache_service.dart';
import 'package:sanal_mahkeme/models/karar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    final cacheService = CacheService();
    await cacheService.clearCache();
  });

  Karar sampleKarar({String hakliKisi = 'Taraf 1', int haksizlikOrani = 50}) {
    return Karar(
      hakliKisi: hakliKisi,
      haksizlikOrani: haksizlikOrani,
      gerekce: 'Test gerekcesi',
      ceza: 'Test cezasi',
      hakimYorumu: 'Test yorumu',
      juriTipi: 'Agir Ceza Reisi',
    );
  }

  group('CacheService', () {
    test('bos cache null dondurur', () async {
      final cacheService = CacheService();
      final decision = await cacheService.getCachedDecision('test metin', 'juri_1');
      expect(decision, isNull);
    });

    test('kaydedilen karar cache\'ten okunur', () async {
      final cacheService = CacheService();
      final karar = sampleKarar(hakliKisi: 'Taraf 1', haksizlikOrani: 45);

      await cacheService.cacheDecision('test metin', 'juri_1', karar);
      final cached = await cacheService.getCachedDecision('test metin', 'juri_1');

      expect(cached, isNotNull);
      expect(cached!.hakliKisi, 'Taraf 1');
      expect(cached.haksizlikOrani, 45);
    });

    test('farkli juri tipleri farkli cache key uretir', () async {
      final cacheService = CacheService();
      final karar1 = sampleKarar(hakliKisi: 'Taraf 1');
      final karar2 = sampleKarar(hakliKisi: 'Taraf 2');

      await cacheService.cacheDecision('ayni metin', 'juri_1', karar1);
      await cacheService.cacheDecision('ayni metin', 'juri_2', karar2);

      final cached1 = await cacheService.getCachedDecision('ayni metin', 'juri_1');
      final cached2 = await cacheService.getCachedDecision('ayni metin', 'juri_2');

      expect(cached1!.hakliKisi, 'Taraf 1');
      expect(cached2!.hakliKisi, 'Taraf 2');
    });

    test('farkli metinler farkli cache key uretir', () async {
      final cacheService = CacheService();
      final karar = sampleKarar();

      await cacheService.cacheDecision('metin A', 'juri_1', karar);
      final cached = await cacheService.getCachedDecision('metin B', 'juri_1');

      expect(cached, isNull);
    });

    test('clearCache tum cache\'i temizler', () async {
      final cacheService = CacheService();
      final karar = sampleKarar();

      await cacheService.cacheDecision('metin 1', 'juri_1', karar);
      await cacheService.cacheDecision('metin 2', 'juri_2', karar);

      await cacheService.clearCache();

      final count = await cacheService.getCacheCount();
      expect(count, 0);
    });

    test('cache sayisi dogru hesaplanir', () async {
      final cacheService = CacheService();
      final karar = sampleKarar();

      await cacheService.cacheDecision('metin 1', 'juri_1', karar);
      await cacheService.cacheDecision('metin 2', 'juri_2', karar);
      await cacheService.cacheDecision('metin 3', 'juri_3', karar);

      final count = await cacheService.getCacheCount();
      expect(count, 3);
    });

    test('cache boyutu veri varken 0 dan buyuk', () async {
      final cacheService = CacheService();
      final karar = sampleKarar();

      await cacheService.cacheDecision('test metin', 'juri_1', karar);

      final size = await cacheService.getCacheSize();
      expect(size, greaterThan(0));
    });
  });
}
