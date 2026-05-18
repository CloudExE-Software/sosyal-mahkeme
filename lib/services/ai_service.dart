import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/juri_type.dart';
import '../models/karar.dart';
import '../utils/constants.dart';
import '../utils/api_keys.dart';
import '../utils/error_handler.dart';
import 'user_preferences_service.dart';
import 'cache_service.dart';
import 'rate_limiter.dart';
import 'analytics_service.dart';

/// AI Servisi — Gemini 2.0 Flash API ile konuşma analizi
/// (OpenAI'den Gemini'ye geçildi — tamamen ücretsiz)
class AIService {
  // Singleton pattern
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Metni Gemini API'ye gönderip karar al
  Future<Karar?> analyzeText({
    required String metin,
    required String juriTipiId,
    bool skipRateLimit = false,
  }) async {
    try {
      // Rate limit kontrolü
      if (!skipRateLimit) {
        await RateLimiter().checkRateLimit();
      }

      // Cache kontrolü
      final cachedDecision = await CacheService().getCachedDecision(metin, juriTipiId);
      if (cachedDecision != null) {
        await AnalyticsService().logAnalysisCompleted(
          juryType: JuriType.getById(juriTipiId).name,
          verdict: cachedDecision.hakliKisi,
          guiltPercentage: cachedDecision.haksizlikOrani,
          cached: true,
        );
        return cachedDecision;
      }

      // API anahtarını kontrol et
      if (Constants.isDemoMode) {
        return _generateDemoDecision(juriTipiId, metin);
      }

      // Jüri tipini getir
      final juriType = JuriType.getById(juriTipiId);

      // Cinsiyet bağlamını ekle
      final userPrefs = UserPreferencesService();
      final genderContext = userPrefs.getUserGenderContext();

      // Analytics
      await AnalyticsService().logAnalysisStarted(
        juryType: juriType.name,
        textLength: metin.length,
        fromOCR: false,
      );

      // Gemini API isteği
      final apiKey = ApiKeys.geminiApiKey;
      final model = Constants.geminiModelName;
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

      // System instruction + user prompt
      final fullPrompt = '${juriType.systemPrompt}\n\n$genderContext\n\n'
          'Şu tartışmayı/konuşmayı analiz et. SADECE JSON formatında yanıt ver:\n\n$metin';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': fullPrompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2000,
            'responseMimeType': 'application/json',
          },
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('API isteği zaman aşımına uğradı'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        final kararData = jsonDecode(content);

        final karar = Karar(
          hakliKisi: kararData['hakli_kisi'] ?? 'Belirsiz',
          haksizlikOrani: kararData['haksizlik_orani'] ?? 50,
          gerekce: kararData['gerekce'] ?? 'Analiz tamamlanamadı',
          ceza: kararData['ceza'] ?? 'Ceza belirlenmedi',
          hakimYorumu: kararData['hakim_yorumu'] ?? '',
          juriTipi: juriType.name,
        );

        await RateLimiter().recordRequest();
        await CacheService().cacheDecision(metin, juriTipiId, karar);

        await AnalyticsService().logAnalysisCompleted(
          juryType: juriType.name,
          verdict: karar.hakliKisi,
          guiltPercentage: karar.haksizlikOrani,
          cached: false,
        );

        return karar;
      } else if (response.statusCode == 429) {
        throw RateLimitException(60);
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        throw APIException('Geçersiz Gemini API anahtarı');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']?['message'] ?? 'Bilinmeyen hata';
        throw APIException(errorMsg);
      }
    } on TimeoutException {
      await AnalyticsService().logNetworkError('timeout');
      rethrow;
    } on FormatException catch (e, stackTrace) {
      await AnalyticsService().logError(e, stackTrace);
      ErrorHandler.logError(e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      await AnalyticsService().logError(e, stackTrace);
      ErrorHandler.logError(e, stackTrace);

      if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException')) {
        throw NetworkException();
      }
      rethrow;
    }
  }

  /// Demo/Test için sahte karar üret (API anahtarı yokken test için)
  Karar _generateDemoDecision(String juriTipiId, String metin) {
    final juriType = JuriType.getById(juriTipiId);
    // Metin içeriğine göre dinamik demo karar üret
    final metinHash = metin.length % 100;
    final isTaraf1Hakli = metinHash > 50;
    return Karar(
      hakliKisi: isTaraf1Hakli ? 'Taraf 1' : 'Taraf 2',
      haksizlikOrani: isTaraf1Hakli ? 30 : 70,
      gerekce: 'Bu bir DEMO karardır. Gerçek analiz için constants.dart dosyasına Gemini API anahtarı ekleyin. '
          'Tartışmanın uzunluğu ${metin.length} karakter olarak tespit edilmiştir. '
          '${isTaraf1Hakli ? 'Taraf 1 argümanları daha tutarlı görünmektedir.' : 'Taraf 2 savunması daha ağır basmaktadır.'}',
      ceza: 'Bir hafta boyunca tartışmayı kazanan kişiye kahve ısmarlamak',
      hakimYorumu: 'Tartışmada mantık değil, ses tonu kazanıyor. Bu kabul edilemez.',
      juriTipi: juriType.name,
    );
  }
}
