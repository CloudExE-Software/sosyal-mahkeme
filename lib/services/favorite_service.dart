import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';
import 'dart:convert';

/// Favori kararları yönetir
class FavoriteService {
  static const String _favoritesKey = 'favorite_decisions';
  static const int _maxFavorites = 100;

  // Singleton
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  /// Favorileri getir
  Future<List<HistoryItem>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      return favoritesJson.map((json) {
        try {
          return HistoryItem.fromJson(jsonDecode(json));
        } catch (e) {
          return null;
        }
      }).whereType<HistoryItem>().toList();
    } catch (e) {
      return [];
    }
  }

  /// Favorilere ekle
  Future<bool> addToFavorites(HistoryItem item) async {
    try {
      final favorites = await getFavorites();
      
      // Zaten favoride mi?
      if (favorites.any((fav) => fav.id == item.id)) {
        return false;
      }
      
      // Limit kontrolü
      if (favorites.length >= _maxFavorites) {
        // En eski favoriyi çıkar
        favorites.removeAt(0);
      }
      
      // Yeni favoriyi ekle
      final updatedItem = HistoryItem(
        id: item.id,
        karar: item.karar,
        davaMetni: item.davaMetni,
        tarih: item.tarih,
        isFavorite: true,
      );
      
      favorites.add(updatedItem);
      
      // Kaydet
      await _saveFavorites(favorites);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Favorilerden çıkar
  Future<bool> removeFromFavorites(String itemId) async {
    try {
      final favorites = await getFavorites();
      final initialLength = favorites.length;
      
      favorites.removeWhere((item) => item.id == itemId);
      
      if (favorites.length == initialLength) {
        return false; // Zaten favoride değildi
      }
      
      await _saveFavorites(favorites);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Favori mi kontrol et
  Future<bool> isFavorite(String itemId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((item) => item.id == itemId);
    } catch (e) {
      return false;
    }
  }

  /// Toggle favorite
  Future<bool> toggleFavorite(HistoryItem item) async {
    final isFav = await isFavorite(item.id);
    if (isFav) {
      return await removeFromFavorites(item.id);
    } else {
      return await addToFavorites(item);
    }
  }

  /// Favori sayısı
  Future<int> getFavoriteCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  /// Tüm favorileri temizle
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }

  /// Favorileri kaydet (internal)
  Future<void> _saveFavorites(List<HistoryItem> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = favorites.map((item) {
      return jsonEncode(item.toJson());
    }).toList();
    
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  /// Favori ara (metin bazlı)
  Future<List<HistoryItem>> searchFavorites(String query) async {
    if (query.trim().isEmpty) {
      return await getFavorites();
    }
    
    final favorites = await getFavorites();
    final lowerQuery = query.toLowerCase();
    
    return favorites.where((item) {
      return item.davaMetni.toLowerCase().contains(lowerQuery) ||
             item.karar.gerekce.toLowerCase().contains(lowerQuery) ||
             item.karar.hakliKisi.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Favorileri tarihe göre sırala
  Future<List<HistoryItem>> getFavoritesSorted({bool ascending = false}) async {
    final favorites = await getFavorites();
    favorites.sort((a, b) {
      return ascending 
          ? a.tarih.compareTo(b.tarih)
          : b.tarih.compareTo(a.tarih);
    });
    return favorites;
  }

  /// Jüri tipine göre favorileri filtrele
  Future<List<HistoryItem>> getFavoritesByJury(String juryId) async {
    final favorites = await getFavorites();
    return favorites.where((item) {
      return item.karar.juriTipi == juryId;
    }).toList();
  }
}
