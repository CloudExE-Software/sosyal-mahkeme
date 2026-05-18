import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';
import 'logger_service.dart';

/// Service for managing accessibility features
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  final FlutterTts _tts = FlutterTts();
  
  // Preferences keys
  static const String _keyVoiceGuidanceEnabled = 'voice_guidance_enabled';
  static const String _keyHighContrastEnabled = 'high_contrast_enabled';
  static const String _keyFontScale = 'font_scale';
  static const String _keyReduceAnimations = 'reduce_animations';
  static const String _keyTtsRate = 'tts_rate';
  static const String _keyTtsPitch = 'tts_pitch';
  static const String _keyTtsLanguage = 'tts_language';

  bool _voiceGuidanceEnabled = false;
  bool _highContrastEnabled = false;
  double _fontScale = 1.0;
  bool _reduceAnimations = false;
  double _ttsRate = 0.5;
  double _ttsPitch = 1.0;
  String _ttsLanguage = 'tr-TR';

  bool get voiceGuidanceEnabled => _voiceGuidanceEnabled;
  bool get highContrastEnabled => _highContrastEnabled;
  double get fontScale => _fontScale;
  bool get reduceAnimations => _reduceAnimations;

  /// Initialize accessibility service
  Future<void> initialize() async {
    try {
      await _loadPreferences();
      await _configureTTS();
      LoggerService.info('AccessibilityService initialized');
    } catch (e) {
      LoggerService.error('Failed to initialize AccessibilityService: $e');
    }
  }

  /// Load saved preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _voiceGuidanceEnabled = prefs.getBool(_keyVoiceGuidanceEnabled) ?? false;
    _highContrastEnabled = prefs.getBool(_keyHighContrastEnabled) ?? false;
    _fontScale = prefs.getDouble(_keyFontScale) ?? 1.0;
    _reduceAnimations = prefs.getBool(_keyReduceAnimations) ?? false;
    _ttsRate = prefs.getDouble(_keyTtsRate) ?? 0.5;
    _ttsPitch = prefs.getDouble(_keyTtsPitch) ?? 1.0;
    _ttsLanguage = prefs.getString(_keyTtsLanguage) ?? 'tr-TR';
  }

  /// Configure TTS engine
  Future<void> _configureTTS() async {
    await _tts.setLanguage(_ttsLanguage);
    await _tts.setSpeechRate(_ttsRate);
    await _tts.setPitch(_ttsPitch);
    await _tts.setVolume(1.0);

    // iOS specific
    await _tts.setSharedInstance(true);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );
  }

  /// Speak text using TTS
  Future<void> speak(String text) async {
    if (!_voiceGuidanceEnabled) return;

    try {
      await _tts.speak(text);
      AnalyticsService().logEvent(
        'tts_speak',
        parameters: {'text_length': text.length},
      );
    } catch (e) {
      LoggerService.error('TTS speak failed: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Announce for screen readers (without TTS)
  void announceForAccessibility(BuildContext context, String message) {
    if (!_voiceGuidanceEnabled) return;
    
    // Create announcement widget for screen readers
    Future.delayed(Duration.zero, () {
      if (context.mounted) {
        // Use semantics to announce
        speak(message);
      }
    });
  }

  // Voice Guidance Settings

  Future<void> setVoiceGuidanceEnabled(bool enabled) async {
    _voiceGuidanceEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVoiceGuidanceEnabled, enabled);

    if (!enabled) {
      await stop();
    }

    AnalyticsService().logEvent(
      'voice_guidance_toggled',
      parameters: {'enabled': enabled.toString()},
    );
  }

  Future<void> setTtsRate(double rate) async {
    _ttsRate = rate;
    await _tts.setSpeechRate(rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTtsRate, rate);
  }

  Future<void> setTtsPitch(double pitch) async {
    _ttsPitch = pitch;
    await _tts.setPitch(pitch);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTtsPitch, pitch);
  }

  Future<void> setTtsLanguage(String language) async {
    _ttsLanguage = language;
    await _tts.setLanguage(language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTtsLanguage, language);
  }

  // High Contrast Mode

  Future<void> setHighContrastEnabled(bool enabled) async {
    _highContrastEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHighContrastEnabled, enabled);

    AnalyticsService().logEvent(
      'high_contrast_toggled',
      parameters: {'enabled': enabled.toString()},
    );
  }

  // Font Scaling

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontScale, scale);

    AnalyticsService().logEvent(
      'font_scale_changed',
      parameters: {'scale': scale.toString()},
    );
  }

  String getFontScaleLabel(double scale) {
    if (scale <= 0.8) return 'Küçük';
    if (scale <= 1.0) return 'Orta';
    if (scale <= 1.2) return 'Büyük';
    return 'Çok Büyük';
  }

  // Reduce Animations

  Future<void> setReduceAnimations(bool enabled) async {
    _reduceAnimations = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReduceAnimations, enabled);

    AnalyticsService().logEvent(
      'reduce_animations_toggled',
      parameters: {'enabled': enabled.toString()},
    );
  }

  // Helper methods for common UI announcements

  Future<void> announceScreenChange(String screenName) async {
    await speak('$screenName ekranına geçildi');
  }

  Future<void> announceButtonPress(String buttonName) async {
    await speak('$buttonName butonuna basıldı');
  }

  Future<void> announceError(String error) async {
    await speak('Hata: $error');
  }

  Future<void> announceSuccess(String message) async {
    await speak('Başarılı: $message');
  }

  Future<void> announceLoading() async {
    await speak('Yükleniyor, lütfen bekleyin');
  }

  Future<void> announceLoadingComplete() async {
    await speak('Yükleme tamamlandı');
  }

  // Get available TTS languages
  Future<List<dynamic>> getAvailableLanguages() async {
    try {
      return await _tts.getLanguages ?? [];
    } catch (e) {
      LoggerService.error('Failed to get TTS languages: $e');
      return [];
    }
  }

  // Test TTS with sample text
  Future<void> testTTS() async {
    await speak('Sesli rehber testi. Bu bir test mesajıdır.');
  }

  void dispose() {
    _tts.stop();
  }
}

/// Extension for adding semantic labels to widgets
extension SemanticLabelExtension on Widget {
  Widget withSemantic({
    required String label,
    String? hint,
    bool? button,
    bool? header,
    bool? focusable,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button ?? false,
      header: header ?? false,
      focusable: focusable ?? true,
      child: this,
    );
  }
}
