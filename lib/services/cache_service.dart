import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/karar.dart';

/// Cache servisi - Aynı metinleri tekrar analiz etmemek için
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _cachePrefix = 'cache_';
  static const int _cacheDurationHours = 24; // 24 saat cache

  SharedPreferences? _prefs;

  /// Initialize
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Metin için cache key oluştur (MD5 hash)
  String _generateCacheKey(String text, String juriTipiId) {
    final combined = '$text|$juriTipiId';
    final bytes = utf8.encode(combined);
    final digest = md5.convert(bytes);
    return '$_cachePrefix${digest.toString()}';
  }

  /// Cache'ten karar getir
  Future<Karar?> getCachedDecision(String text, String juriTipiId) async {
    await init();

    final key = _generateCacheKey(text, juriTipiId);
    final jsonString = _prefs?.getString(key);

    if (jsonString == null) {
      return null;
    }

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      // Cache süresini kontrol et
      final cachedTime = DateTime.parse(json['cached_at'] as String);
      final now = DateTime.now();
      final difference = now.difference(cachedTime).inHours;

      if (difference > _cacheDurationHours) {
        // Cache süresi dolmuş, sil
        await _prefs?.remove(key);
        return null;
      }

      return Karar.fromJson(json['karar'] as Map<String, dynamic>);
    } catch (e) {
      // Hatalı cache verisi, sil
      await _prefs?.remove(key);
      return null;
    }
  }

  /// Kararı cache'e kaydet
  Future<void> cacheDecision(String text, String juriTipiId, Karar karar) async {
    await init();

    final key = _generateCacheKey(text, juriTipiId);
    final data = {
      'karar': karar.toJson(),
      'cached_at': DateTime.now().toIso8601String(),
    };

    await _prefs?.setString(key, jsonEncode(data));
  }

  /// Tüm cache'i temizle
  Future<void> clearCache() async {
    await init();

    final keys = _prefs?.getKeys() ?? {};
    for (var key in keys) {
      if (key.startsWith(_cachePrefix)) {
        await _prefs?.remove(key);
      }
    }
  }

  /// Cache boyutunu getir (MB)
  Future<double> getCacheSize() async {
    await init();

    final keys = _prefs?.getKeys() ?? {};
    int totalBytes = 0;

    for (var key in keys) {
      if (key.startsWith(_cachePrefix)) {
        final value = _prefs?.getString(key) ?? '';
        totalBytes += utf8.encode(value).length;
      }
    }

    return totalBytes / (1024 * 1024); // MB'ye çevir
  }

  /// Cache'lenmiş öğe sayısı
  Future<int> getCacheCount() async {
    await init();

    final keys = _prefs?.getKeys() ?? {};
    return keys.where((key) => key.startsWith(_cachePrefix)).length;
  }
}
