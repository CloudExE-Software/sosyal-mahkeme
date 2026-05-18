import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  /// Uygulama başlığı
  ///
  /// In tr, this message translates to:
  /// **'Sanal Mahkeme'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Haklı Kim?'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka destekli sanal mahkeme sistemi'**
  String get homeSubtitle;

  /// No description provided for @startButton.
  ///
  /// In tr, this message translates to:
  /// **'Davaya Başla'**
  String get startButton;

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get continueButton;

  /// No description provided for @cancelButton.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get saveButton;

  /// No description provided for @deleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get deleteButton;

  /// No description provided for @okButton.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get okButton;

  /// No description provided for @yesButton.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yesButton;

  /// No description provided for @noButton.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get noButton;

  /// No description provided for @selectJury.
  ///
  /// In tr, this message translates to:
  /// **'Jüri Seçimi'**
  String get selectJury;

  /// No description provided for @selectJuryDescription.
  ///
  /// In tr, this message translates to:
  /// **'Davanızı değerlendirecek jüriyi seçin'**
  String get selectJuryDescription;

  /// No description provided for @enterCase.
  ///
  /// In tr, this message translates to:
  /// **'Davanızı Anlatın'**
  String get enterCase;

  /// No description provided for @enterCaseHint.
  ///
  /// In tr, this message translates to:
  /// **'Davanızı detaylı bir şekilde yazın...'**
  String get enterCaseHint;

  /// No description provided for @analyzing.
  ///
  /// In tr, this message translates to:
  /// **'Analiz ediliyor...'**
  String get analyzing;

  /// No description provided for @verdict.
  ///
  /// In tr, this message translates to:
  /// **'Karar'**
  String get verdict;

  /// No description provided for @explanation.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get explanation;

  /// No description provided for @history.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get history;

  /// No description provided for @favorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get favorites;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @premium.
  ///
  /// In tr, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @analytics.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get analytics;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Mod'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @fontSize.
  ///
  /// In tr, this message translates to:
  /// **'Yazı Boyutu'**
  String get fontSize;

  /// No description provided for @highContrast.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Kontrast'**
  String get highContrast;

  /// No description provided for @screenReader.
  ///
  /// In tr, this message translates to:
  /// **'Ekran Okuyucu'**
  String get screenReader;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In tr, this message translates to:
  /// **'Arapça'**
  String get arabic;

  /// No description provided for @small.
  ///
  /// In tr, this message translates to:
  /// **'Küçük'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In tr, this message translates to:
  /// **'Büyük'**
  String get large;

  /// No description provided for @extraLarge.
  ///
  /// In tr, this message translates to:
  /// **'Çok Büyük'**
  String get extraLarge;

  /// No description provided for @premiumTitle.
  ///
  /// In tr, this message translates to:
  /// **'Premium Üyelik'**
  String get premiumTitle;

  /// No description provided for @premiumDescription.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız dava ve özel jüriler'**
  String get premiumDescription;

  /// No description provided for @monthlyPlan.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get monthlyPlan;

  /// No description provided for @yearlyPlan.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get yearlyPlan;

  /// No description provided for @lifetimePlan.
  ///
  /// In tr, this message translates to:
  /// **'Ömür Boyu'**
  String get lifetimePlan;

  /// No description provided for @notificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get notificationSettings;

  /// No description provided for @caseUpdates.
  ///
  /// In tr, this message translates to:
  /// **'Dava Güncellemeleri'**
  String get caseUpdates;

  /// No description provided for @juryRecommendations.
  ///
  /// In tr, this message translates to:
  /// **'Jüri Önerileri'**
  String get juryRecommendations;

  /// No description provided for @weeklyDigest.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Özet'**
  String get weeklyDigest;

  /// No description provided for @promotions.
  ///
  /// In tr, this message translates to:
  /// **'Kampanyalar'**
  String get promotions;

  /// No description provided for @dailyReminder.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Hatırlatma'**
  String get dailyReminder;

  /// No description provided for @accessibility.
  ///
  /// In tr, this message translates to:
  /// **'Erişilebilirlik'**
  String get accessibility;

  /// No description provided for @accessibilitySettings.
  ///
  /// In tr, this message translates to:
  /// **'Erişilebilirlik Ayarları'**
  String get accessibilitySettings;

  /// No description provided for @voiceGuidance.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Rehber'**
  String get voiceGuidance;

  /// No description provided for @enableVoiceGuidance.
  ///
  /// In tr, this message translates to:
  /// **'Sesli rehberi etkinleştir'**
  String get enableVoiceGuidance;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get version;

  /// No description provided for @rateApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Oyla'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Paylaş'**
  String get shareApp;

  /// No description provided for @contactUs.
  ///
  /// In tr, this message translates to:
  /// **'İletişim'**
  String get contactUs;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @success.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi'**
  String get info;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In tr, this message translates to:
  /// **'Veri bulunamadı'**
  String get noData;

  /// No description provided for @noInternet.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok'**
  String get noInternet;

  /// No description provided for @deleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Silmek istediğinize emin misiniz?'**
  String get deleteConfirm;

  /// No description provided for @deleteSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla silindi'**
  String get deleteSuccess;

  /// No description provided for @saveSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla kaydedildi'**
  String get saveSuccess;

  /// No description provided for @premiumRequired.
  ///
  /// In tr, this message translates to:
  /// **'Premium Üyelik Gerekli'**
  String get premiumRequired;

  /// No description provided for @premiumRequiredDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik premium üyelere özeldir'**
  String get premiumRequiredDescription;

  /// No description provided for @upgradeToPremium.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a Yükselt'**
  String get upgradeToPremium;

  /// No description provided for @comparison.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştırma'**
  String get comparison;

  /// No description provided for @compareJuries.
  ///
  /// In tr, this message translates to:
  /// **'Jürileri Karşılaştır'**
  String get compareJuries;

  /// No description provided for @voiceInput.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Giriş'**
  String get voiceInput;

  /// No description provided for @useVoice.
  ///
  /// In tr, this message translates to:
  /// **'Sesli Kayıt Kullan'**
  String get useVoice;

  /// No description provided for @cloudSync.
  ///
  /// In tr, this message translates to:
  /// **'Bulut Senkronizasyonu'**
  String get cloudSync;

  /// No description provided for @syncNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Senkronize Et'**
  String get syncNow;

  /// No description provided for @lastSync.
  ///
  /// In tr, this message translates to:
  /// **'Son Senkronizasyon'**
  String get lastSync;

  /// No description provided for @autoSync.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Senkronizasyon'**
  String get autoSync;

  /// No description provided for @security.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get security;

  /// No description provided for @dataEncryption.
  ///
  /// In tr, this message translates to:
  /// **'Veri Şifreleme'**
  String get dataEncryption;

  /// No description provided for @biometricAuth.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik Kimlik Doğrulama'**
  String get biometricAuth;

  /// No description provided for @offlineMode.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı Mod'**
  String get offlineMode;

  /// No description provided for @offlineModeDescription.
  ///
  /// In tr, this message translates to:
  /// **'İnternet olmadan çalışır'**
  String get offlineModeDescription;

  /// No description provided for @onboarding1Title.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Description.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka destekli sanal mahkeme sistemine hoş geldiniz'**
  String get onboarding1Description;

  /// No description provided for @onboarding2Title.
  ///
  /// In tr, this message translates to:
  /// **'Jüri Seçin'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Description.
  ///
  /// In tr, this message translates to:
  /// **'Farklı perspektiflerden davanızı değerlendirin'**
  String get onboarding2Description;

  /// No description provided for @onboarding3Title.
  ///
  /// In tr, this message translates to:
  /// **'Karar Alın'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Description.
  ///
  /// In tr, this message translates to:
  /// **'Anında objektif değerlendirme ve öneriler'**
  String get onboarding3Description;

  /// No description provided for @onboarding4Title.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedin ve Paylaşın'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Description.
  ///
  /// In tr, this message translates to:
  /// **'Kararlarınızı saklayın ve paylaşın'**
  String get onboarding4Description;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Geç'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In tr, this message translates to:
  /// **'Başlayalım'**
  String get getStarted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
