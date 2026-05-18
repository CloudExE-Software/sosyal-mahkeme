import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcı tercihlerini yöneten servis
class UserPreferencesService {
  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  SharedPreferences? _prefs;

  /// Initialize
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Onboarding tamamlandı mı?
  bool get hasCompletedOnboarding {
    return _prefs?.getBool('onboarding_completed') ?? false;
  }

  /// Kullanıcı cinsiyeti
  String? get userGender {
    return _prefs?.getString('user_gender');
  }

  /// Cinsiyet kaydet
  Future<void> setUserGender(String gender) async {
    await _prefs?.setString('user_gender', gender);
  }

  /// Onboarding tamamla
  Future<void> completeOnboarding() async {
    await _prefs?.setBool('onboarding_completed', true);
  }

/// Tüm verileri temizle (çıkış/reset için)
  Future<void> clear() async {
    await _prefs?.clear();
  }

  /// Reklam gösterimi tercihi
  bool get showAds {
    return _prefs?.getBool('show_ads') ?? true;
  }

  /// Reklam tercihi kaydet
  Future<void> setShowAds(bool value) async {
    await _prefs?.setBool('show_ads', value);
  }

  /// Cinsiyet açıklaması (AI için)
  String getUserGenderContext() {
    final gender = userGender;
    if (gender == 'female') {
      return 'Kullanıcı kadın. Kadınların bakış açısını ve deneyimlerini göz önünde bulundur.';
    } else if (gender == 'male') {
      return 'Kullanıcı erkek. Erkeklerin bakış açısını ve deneyimlerini göz önünde bulundur.';
    }
    return 'Kullanıcı cinsiyeti belirtilmemiş. Tarafsız bir bakış açısı kullan.';
  }
}
