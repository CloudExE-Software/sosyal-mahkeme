import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'services/ad_service.dart';
import 'services/user_preferences_service.dart';
import 'services/history_service.dart';
import 'services/cache_service.dart';
import 'services/rate_limiter.dart';
import 'services/analytics_service.dart';
import 'services/theme_service.dart';
import 'services/connectivity_service.dart';
import 'services/subscription_service.dart';
import 'services/accessibility_service.dart';
import 'services/language_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'l10n/app_localizations.dart';

/// Global navigator key for app-wide navigation
class AppNavigatorKey {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await UserPreferencesService().init();
  await HistoryService().init();
  await CacheService().init();
  await RateLimiter().init();
  await AnalyticsService().init();
  await ThemeService().loadThemeMode();

  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('en_US', null);
  await initializeDateFormatting('ar', null);

  final optionalServices = <Future<dynamic> Function()>[
    () => SubscriptionService().initialize(),
    () => Future.wait<dynamic>([
      AccessibilityService().initialize(),
      LanguageService().initialize(),
    ]),
    () => ConnectivityService().initialize(),
  ];

  for (final service in optionalServices) {
    try {
      await service();
    } catch (e) {
      debugPrint('Hizmet başlatılamadı: $e');
    }
  }

  if (Constants.showAds) {
    try {
      await AdService().initialize();
    } catch (e) {
      debugPrint('AdMob başlatılamadı: $e');
    }
  }

  runApp(const SanalMahkemeApp());
}

class SanalMahkemeApp extends StatefulWidget {
  const SanalMahkemeApp({super.key});

  @override
  State<SanalMahkemeApp> createState() => _SanalMahkemeAppState();
}

class _SanalMahkemeAppState extends State<SanalMahkemeApp> {
  final _languageService = LanguageService();

  @override
  Widget build(BuildContext context) {
    // Onboarding tamamlanmış mı kontrol et
    final hasCompletedOnboarding = UserPreferencesService().hasCompletedOnboarding;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Haklı Kim ?',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          navigatorKey: AppNavigatorKey.key,
          home: hasCompletedOnboarding ? const HomeScreen() : const OnboardingScreen(),
          
          // Localization
          locale: _languageService.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr'),
            Locale('en'),
            Locale('ar'),
          ],
          
          // Route configuration
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
              settings: settings,
            );
          },
        );
      },
    );
  }
}
