import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';
import 'logger_service.dart';

/// Google AdMob reklam yönetim servisi
class AdService {
  // Singleton pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;

  /// AdMob'u başlat
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd(); // Karar ekranı öncesi için hazır tut
  }

  // ==================== BANNER REKLAM ====================
  
  /// Banner reklamı yükle
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          LoggerService.info('Banner reklam yüklendi', tag: 'AdService');
          _isBannerAdReady = true;
        },
        onAdFailedToLoad: (ad, error) {
          LoggerService.error('Banner reklam yüklenemedi', tag: 'AdService', error: error);
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  BannerAd? get bannerAd => _isBannerAdReady ? _bannerAd : null;

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;
  }

  // ==================== INTERSTITIAL REKLAM ====================

  /// Geçiş reklamı yükle (Karar ekranı öncesi)
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          LoggerService.info('Geçiş reklamı yüklendi', tag: 'AdService');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              LoggerService.info('Geçiş reklamı kapatıldı', tag: 'AdService');
              ad.dispose();
              _loadInterstitialAd(); // Yeni reklam yükle
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              LoggerService.error('Geçiş reklamı gösterilemedi', tag: 'AdService', error: error);
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          LoggerService.error('Geçiş reklamı yüklenemedi', tag: 'AdService', error: error);
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// Geçiş reklamını göster
  Future<void> showInterstitialAd({Function? onAdClosed}) async {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      // Callback'i bir değişkende tut
      final callback = onAdClosed;
      
      // Full screen callback'i güncelle
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          LoggerService.info('Geçiş reklamı kapatıldı', tag: 'AdService');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdReady = false;
          _loadInterstitialAd(); // Yeni reklam yükle
          
          // Callback'i çağır
          try {
            callback?.call();
          } catch (e) {
            LoggerService.error('Ad callback error', tag: 'AdService', error: e);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          LoggerService.error('Geçiş reklamı gösterilemedi', tag: 'AdService', error: error);
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdReady = false;
          _loadInterstitialAd();
          
          // Hata durumunda da callback'i çağır
          try {
            callback?.call();
          } catch (e) {
            LoggerService.error('Ad callback error', tag: 'AdService', error: e);
          }
        },
      );
      
      await _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      LoggerService.warning('Geçiş reklamı henüz hazır değil', tag: 'AdService');
      // Reklam yoksa direkt devam et
      try {
        onAdClosed?.call();
      } catch (e) {
        LoggerService.error('Ad callback error', tag: 'AdService', error: e);
      }
    }
  }

  // ==================== REWARDED REKLAM ====================

  /// Ödüllü reklam yükle (Premium özellikler için)
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _getRewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          LoggerService.info('Ödüllü reklam yüklendi', tag: 'AdService');
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              LoggerService.info('Ödüllü reklam kapatıldı', tag: 'AdService');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdReady = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              LoggerService.error('Ödüllü reklam gösterilemedi', tag: 'AdService', error: error);
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          LoggerService.error('Ödüllü reklam yüklenemedi', tag: 'AdService', error: error);
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  /// Ödüllü reklamı göster
  Future<bool> showRewardedAd() async {
    if (_isRewardedAdReady && _rewardedAd != null) {
      bool rewardEarned = false;

      await _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          LoggerService.info('Kullanıcı ödülü kazandı: ${reward.amount} ${reward.type}', tag: 'AdService');
          rewardEarned = true;
        },
      );

      return rewardEarned;
    } else {
      LoggerService.warning('Ödüllü reklam henüz hazır değil', tag: 'AdService');
      return false;
    }
  }

  // ==================== AD UNIT ID'LER ====================

  String _getBannerAdUnitId() {
    if (Constants.adMobBannerId.isNotEmpty) {
      return Constants.adMobBannerId;
    }
    // Test reklamları
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test Banner ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test Banner ID
    }
    return '';
  }

  String _getInterstitialAdUnitId() {
    if (Constants.adMobInterstitialId.isNotEmpty) {
      return Constants.adMobInterstitialId;
    }
    // Test reklamları
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test Interstitial ID
    }
    return '';
  }

  String _getRewardedAdUnitId() {
    if (Constants.adMobRewardedId.isNotEmpty) {
      return Constants.adMobRewardedId;
    }
    // Test reklamları
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test Rewarded ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test Rewarded ID
    }
    return '';
  }

  /// Cleanup
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
