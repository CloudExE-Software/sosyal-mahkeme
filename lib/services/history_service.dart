import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';
import '../models/karar.dart';

/// Karar geçmişini yöneten servis
class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _historyKey = 'decision_history';
  static const int _maxHistoryItems = 50; // Maksimum 50 karar sakla

  SharedPreferences? _prefs;

  /// Initialize
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Yeni karar ekle
  Future<String> addDecision({
    required String davaMetni,
    required Karar karar,
  }) async {
    await init();

    final history = await getHistory();
    
    // Yeni item oluştur
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newItem = HistoryItem(
      id: id,
      davaMetni: davaMetni,
      karar: karar,
      tarih: DateTime.now(),
    );

    // Başa ekle (en yeni önce)
    history.insert(0, newItem);

    // Maksimum sayıyı aş diyse eski olanları sil
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    // Kaydet
    await _saveHistory(history);
    
    return id;
  }

  /// Tüm geçmişi getir
  Future<List<HistoryItem>> getHistory() async {
    await init();

    final jsonString = _prefs?.getString(_historyKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => HistoryItem.fromJson(json)).toList();
    } catch (e) {
      // Hatalı veri varsa temizle
      await clearHistory();
      return [];
    }
  }

  /// Belirli bir kararı sil
  Future<void> deleteDecision(String id) async {
    await init();

    final history = await getHistory();
    history.removeWhere((item) => item.id == id);
    await _saveHistory(history);
  }

  /// Tüm geçmişi temizle
  Future<void> clearHistory() async {
    await init();
    await _prefs?.remove(_historyKey);
  }

  /// Geçmişi komple değiştir (sync için)
  Future<void> replaceHistory(List<HistoryItem> newHistory) async {
    await init();
    await _saveHistory(newHistory);
  }

  /// Geçmişteki karar sayısı
  Future<int> getHistoryCount() async {
    final history = await getHistory();
    return history.length;
  }

  /// Son N kararı getir
  Future<List<HistoryItem>> getRecentDecisions(int count) async {
    final history = await getHistory();
    if (history.length <= count) {
      return history;
    }
    return history.sublist(0, count);
  }

  /// Geçmişi kaydet (private)
  Future<void> _saveHistory(List<HistoryItem> history) async {
    final jsonList = history.map((item) => item.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs?.setString(_historyKey, jsonString);
  }

  /// Belirli bir metni geçmişte ara (Cache için)
  Future<HistoryItem?> findByText(String text) async {
    final history = await getHistory();
    
    // Tam eşleşme ara
    for (var item in history) {
      if (item.davaMetni.trim() == text.trim()) {
        return item;
      }
    }
    
    return null;
  }
}
