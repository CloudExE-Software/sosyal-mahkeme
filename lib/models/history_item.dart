import 'karar.dart';

/// Geçmiş karar öğesi
class HistoryItem {
  final String id;
  final String davaMetni;
  final Karar karar;
  final DateTime tarih;
  final bool isFavorite;

  HistoryItem({
    required this.id,
    required this.davaMetni,
    required this.karar,
    required this.tarih,
    this.isFavorite = false,
  });

  /// JSON'dan oluştur
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      davaMetni: json['dava_metni'] as String,
      karar: Karar.fromJson(json['karar'] as Map<String, dynamic>),
      tarih: DateTime.parse(json['tarih'] as String),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dava_metni': davaMetni,
      'karar': karar.toJson(),
      'tarih': tarih.toIso8601String(),
      'is_favorite': isFavorite,
    };
  }

  /// Kısa önizleme metni
  String get onizleme {
    if (davaMetni.length <= 100) {
      return davaMetni;
    }
    return '${davaMetni.substring(0, 100)}...';
  }
}
