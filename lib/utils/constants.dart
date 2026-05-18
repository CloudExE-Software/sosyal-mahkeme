import 'api_keys.dart';

/// Uygulama sabitleri ve yapılandırma
///
/// 🔐 API anahtarları burada DEĞİL, api_keys.dart dosyasında
/// (api_keys.dart .gitignore'da — GitHub'a yüklenmez)
///
/// Şablon için: api_keys_template.dart
/// 
/// AdMob IDs almak için: https://apps.admob.com/
class Constants {
  // ==================== API KEYS ====================
  // api_keys.dart içinde tanımlı:
  // - ApiKeys.geminiApiKey  (ana sağlayıcı)
  // - ApiKeys.openAIApiKey  (yedek)
  
  /// Kullanılacak AI sağlayıcısı
  static const String aiProvider = 'gemini'; // 'openai' veya 'gemini'
  
  /// Gemini model adı
  /// 2.5 Flash önerilir (güncel ücretsiz model)
  static const String geminiModelName = 'gemini-2.5-flash';
  
  // ==================== ADMOB IDs ====================
  /// Gerçek AdMob ID'leri (Kullanıcının kendisi)
  static const String adMobAppIdAndroid = 'ca-app-pub-8644626779161677~1556253697';
  static const String adMobAppIdIOS = 'ca-app-pub-8644626779161677~1556253697';
  
  /// Interstitial REKLAM ID (Her analizden önce)
  static const String adMobInterstitialId = 'ca-app-pub-8644626779161677/7555668374';
  
  /// Banner Reklam ID (Ana ekran için)
  static const String adMobBannerId = 'ca-app-pub-8644626779161677/7555668374';
  
  /// Rewarded Reklam ID (İsteğe bağlı)
  static const String adMobRewardedId = 'ca-app-pub-8644626779161677/7555668374';
  
  // ==================== APP CONFIG ====================
  
  /// Uygulama adı
  static const String appName = 'Haklı Kim?';
  
  /// Uygulama sloganı
  static const String appSlogan = 'Yapay Zeka ile Sanal Mahkeme';
  
  /// Günlük ücretsiz dava hakkı
  static const int freeTrialsPerDay = 1;
  
  /// Paylaşım watermark metni
  static const String shareWatermark = 'Haklı Kim ? - AI Analiz\nİndir: cloudexe-software.github.io/sosyal-mahkeme';
  
  /// Support email
  static const String supportEmail = 'destek@sosyalmahkeme.com';
  
  /// Privacy policy URL — GitHub Pages (ücretsiz barındırma)
  static const String privacyPolicyUrl = 'https://cloudexe-software.github.io/sosyal-mahkeme/privacy-policy.html';
  
  /// Terms of service URL — GitHub Pages (ücretsiz barındırma)
  static const String termsOfServiceUrl = 'https://cloudexe-software.github.io/sosyal-mahkeme/terms-of-service.html';
  
  // ==================== FEATURE FLAGS ====================
  
  /// Demo modu (API key yoksa aktif olur)
  /// Gemini key öncelikli, yoksa OpenAI key'e bak
  static bool get isDemoMode {
    if (aiProvider == 'gemini') {
      return ApiKeys.geminiApiKey == 'BURAYA_GEMINI_API_KEY_EKLE' || ApiKeys.geminiApiKey.isEmpty;
    }
    return ApiKeys.openAIApiKey == 'BURAYA_OPENAI_API_KEY_EKLE' || ApiKeys.openAIApiKey.isEmpty;
  }
  
  /// Reklam göster (AKTİF - Interstitial her analiz öncesi ve sonrası)
  static const bool showAds = true;
}
