import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Subscription Service - Freemium Model
/// Tüm özellikler ücretsiz! Reklam destekli.
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  static const String tierFree = 'free';
  static const String tierPremium = 'premium';

  // Freemium: Herkes için sınırsız!
  static const int freeJuryLimit = 999;
  static const int premiumJuryLimit = 999;
  
  static const int freeComparisonLimit = 5;
  static const int premiumComparisonLimit = 5;
  
  static const int freeDailyCaseLimit = 999;
  static const int premiumDailyCaseLimit = 999;

  // Local storage anahtarları
  static const String _dailyCaseCountKey = 'daily_case_count';
  static const String _lastResetDateKey = 'last_reset_date';

  /// Initialize
  Future<void> initialize() async {
    await _resetDailyLimitIfNeeded();
    LoggerService.info('SubscriptionService initialized - Freemium mode');
  }

  /// Kullanıcının mevcut tier'ı
  String get currentTier => tierFree;

  /// Premium üye mi? (Freemium: her zaman false)
  bool get isPremium => false;

  /// Subscription tipi
  String? get subscriptionType => null;

  /// Premium jürilere erişim var mı?
  bool get canAccessPremiumJuries => isPremium;

  /// Karşılaştırmada kullanılabilecek max jüri sayısı
  int get maxComparisonJuries {
    return isPremium ? premiumComparisonLimit : freeComparisonLimit;
  }

  /// Kullanılabilecek max jüri sayısı
  int get maxJuries {
    return isPremium ? premiumJuryLimit : freeJuryLimit;
  }

  /// Günlük kalan dava hakkı
  Future<int> getRemainingDailyCases() async {
    await _resetDailyLimitIfNeeded();
    
    if (isPremium) {
      return premiumDailyCaseLimit;
    }

    final prefs = await SharedPreferences.getInstance();
    final usedCases = prefs.getInt(_dailyCaseCountKey) ?? 0;
    final remaining = freeDailyCaseLimit - usedCases;
    return remaining > 0 ? remaining : 0;
  }

  /// Dava kullanımını kaydet
  Future<bool> consumeDailyCase() async {
    await _resetDailyLimitIfNeeded();
    
    if (isPremium) {
      return true; // Premium sınırsız
    }

    final remaining = await getRemainingDailyCases();
    if (remaining <= 0) {
      LoggerService.warning('Daily case limit reached');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_dailyCaseCountKey) ?? 0;
    await prefs.setInt(_dailyCaseCountKey, currentCount + 1);
    
    LoggerService.info('Daily case consumed. Remaining: ${remaining - 1}');
    return true;
  }

  /// Günlük limiti sıfırla (yeni gün başladıysa)
  Future<void> _resetDailyLimitIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final lastReset = prefs.getString(_lastResetDateKey);

    if (lastReset != today) {
      await prefs.setInt(_dailyCaseCountKey, 0);
      await prefs.setString(_lastResetDateKey, today);
      LoggerService.info('Daily limit reset for $today');
    }
  }

  /// Tüm özellikler artık ücretsiz!
  List<PremiumFeature> get premiumFeatures => [];

  List<PremiumFeature> get freeFeatures => [
    PremiumFeature(
      icon: '⚖️',
      title: 'Tüm Jüriler',
      description: '5 farklı jüri tipi ile analiz',
      isFree: true,
    ),
    PremiumFeature(
      icon: '📝',
      title: 'Sınırsız Analiz',
      description: 'İstediğiniz kadar dava analizi',
      isFree: true,
    ),
    PremiumFeature(
      icon: '🎯',
      title: 'Karşılaştırma',
      description: '5 jüriye kadar karşılaştırma',
      isFree: true,
    ),
    PremiumFeature(
      icon: '📸',
      title: 'Story Paylaşım',
      description: 'Instagram/TikTok için export',
      isFree: true,
    ),
    PremiumFeature(
      icon: '🔒',
      title: 'Şifreli Veri',
      description: 'Tüm verileriniz güvende',
      isFree: true,
    ),
  ];

  List<SubscriptionPlan> get plans => [];

  Future<bool> purchasePlan(String planId) async => false;
  Future<void> restorePurchases() async {}
}

/// Premium özellik modeli
class PremiumFeature {
  final String icon;
  final String title;
  final String description;
  final bool isFree;

  const PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.isFree,
  });
}

/// Subscription planı modeli
class SubscriptionPlan {
  final String id;
  final String name;
  final String price;
  final String period;
  final String? savings;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    this.savings,
    required this.features,
    required this.isPopular,
  });
}
