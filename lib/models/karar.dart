// Mahkeme kararı modeli
import 'package:flutter/material.dart';

class Karar {
  final String hakliKisi;
  final int haksizlikOrani;
  final String gerekce;
  final String ceza;
  final String hakimYorumu;
  final String juriTipi;
  final DateTime kararTarihi;

  Karar({
    required this.hakliKisi,
    required this.haksizlikOrani,
    required this.gerekce,
    required this.ceza,
    required this.hakimYorumu,
    required this.juriTipi,
    DateTime? kararTarihi,
  }) : kararTarihi = kararTarihi ?? DateTime.now();

  // JSON'dan model oluştur
  factory Karar.fromJson(Map<String, dynamic> json) {
    return Karar(
      hakliKisi: json['hakli_kisi'] ?? 'Belirsiz',
      haksizlikOrani: json['haksizlik_orani'] ?? 50,
      gerekce: json['gerekce'] ?? 'Gerekçe belirtilmemiş',
      ceza: json['ceza'] ?? 'Ceza belirlenmemiş',
      hakimYorumu: json['hakim_yorumu'] ?? 'Yorum yok',
      juriTipi: json['juri_tipi'] ?? 'Bilinmiyor',
    );
  }

  // Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'hakli_kisi': hakliKisi,
      'haksizlik_orani': haksizlikOrani,
      'gerekce': gerekce,
      'ceza': ceza,
      'hakim_yorumu': hakimYorumu,
      'juri_tipi': juriTipi,
      'karar_tarihi': kararTarihi.toIso8601String(),
    };
  }

  // Haklılık yüzdesi hesapla
  int get haklilikOrani => 100 - haksizlikOrani;

  // Karar türü (Haklı/Haksız)
  String get kararTuru {
    if (haksizlikOrani <= 30) return 'Büyük Oranda Haklı';
    if (haksizlikOrani <= 50) return 'Kısmen Haklı';
    if (haksizlikOrani <= 70) return 'Kısmen Haksız';
    return 'Büyük Oranda Haksız';
  }

  // Karar emoji
  String get kararEmoji {
    if (haksizlikOrani <= 30) return '✅';
    if (haksizlikOrani <= 50) return '⚖️';
    if (haksizlikOrani <= 70) return '⚠️';
    return '❌';
  }

  // Karar rengi (UI için) - Color objesi döndür
  Color get kararRengi {
    if (haksizlikOrani <= 30) return const Color(0xFF4CAF50); // Yeşil
    if (haksizlikOrani <= 50) return const Color(0xFFFFC107); // Sarı
    if (haksizlikOrani <= 70) return const Color(0xFFFF9800); // Turuncu
    return const Color(0xFFF44336); // Kırmızı
  }
}
