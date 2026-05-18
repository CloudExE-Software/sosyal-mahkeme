import 'package:flutter/foundation.dart';

/// Simple Analytics Service (Local - No Firebase)
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Future<void> init() async {
    // Analytics hazırlık (ileride Firebase/Crashlytics eklenebilir)
  }

  Future<void> logScreenView(String screenName) async {
    debugPrint('[Analytics] Screen viewed: $screenName');
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    debugPrint('[Analytics] Event: $name, params: $parameters');
  }

  Future<void> logOCRUsed(String source) async {
    debugPrint('[Analytics] OCR used from: $source');
  }

  Future<void> logAnalysisStarted({
    required String juryType,
    required int textLength,
    required bool fromOCR,
  }) async {
    debugPrint('[Analytics] Analysis started: jury=$juryType, length=$textLength');
  }

  Future<void> logAnalysisCompleted({
    required String juryType,
    required String verdict,
    required int guiltPercentage,
    required bool cached,
  }) async {
    debugPrint('[Analytics] Analysis completed: jury=$juryType, verdict=$verdict, cached=$cached');
  }

  Future<void> logDecisionShared(String juryType) async {
    debugPrint('[Analytics] Decision shared by: $juryType');
  }

  Future<void> logHistoryViewed() async {
    debugPrint('[Analytics] History viewed');
  }

  Future<void> logSettingsOpened() async {
    debugPrint('[Analytics] Settings opened');
  }

  Future<void> logError(dynamic error, dynamic stackTrace) async {
    debugPrint('[Analytics] Error: $error');
  }

  Future<void> logNetworkError(String type) async {
    debugPrint('[Analytics] Network error: $type');
  }
}