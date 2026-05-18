import 'package:flutter/material.dart';

/// Uygulama tema ve renk paleti
class AppTheme {
  // ==================== RENKLER ====================
  
  /// Ana renkler (Mahkeme teması - Koyu ve ciddi)
  static const Color primaryColor = Color(0xFF1A1A2E); // Koyu lacivert
  static const Color secondaryColor = Color(0xFF16213E); // Orta koyu
  static const Color accentColor = Color(0xFFE94560); // Kırmızı vurgu
  static const Color backgroundColor = Color(0xFF0F1419); // Siyah arka plan
  
  /// Metin renkleri
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8B8);
  static const Color textTertiary = Color(0xFF707070);
  
  /// Karar renkleri
  static const Color successColor = Color(0xFF4CAF50); // Haklı
  static const Color warningColor = Color(0xFFFF9800); // Kısmen / Uyarı
  static const Color errorColor = Color(0xFFF44336); // Haksız / Hata
  static const Color infoColor = Color(0xFF2196F3); // Bilgi
  
  /// Altın (Premium)
  static const Color goldColor = Color(0xFFFFD700);
  
  /// Card rengi
  static const Color cardColor = primaryColor;
  
  // ==================== TEMA ====================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: secondaryColor,
        surface: primaryColor,
        error: errorColor,
      ),
      
      // AppBar teması
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Card teması
      cardTheme: const CardThemeData(
        color: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Button teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Text teması
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      
      // Input teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textTertiary),
      ),
    );
  }
  
  // Light tema
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFFF5F5F5),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      colorScheme: const ColorScheme.light(
        primary: accentColor,
        secondary: Color(0xFFE0E0E0),
        surface: Color(0xFFF5F5F5),
        error: errorColor,
      ),
      
      // AppBar teması
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF000000)),
        titleTextStyle: TextStyle(
          color: Color(0xFF000000),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Card teması
      cardTheme: const CardThemeData(
        color: Color(0xFFF5F5F5),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Button teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Text teması
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF000000),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF000000),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF000000),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF000000),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF000000),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF616161),
          fontSize: 14,
        ),
      ),
      
      // Input teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      ),
    );
  }
  
  // ==================== PADDING & SPACING ====================
  
  static const EdgeInsets pagePadding = EdgeInsets.all(20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double smallSpacing = 8.0;
  
  // ==================== BORDER RADIUS ====================
  
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double inputRadius = 12.0;
}

/// Uygulama boyutları
class AppSizes {
  static const double iconSize = 24.0;
  static const double largeIconSize = 48.0;
  static const double buttonHeight = 56.0;
  static const double cardElevation = 4.0;
}
