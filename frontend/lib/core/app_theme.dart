import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية: الزمردي الإسلامي الفاخر مع لمسات ذهبية
  static const Color primaryEmerald = Color(0xFF0F5132); // Deep emerald
  static const Color primaryDark = Color(0xFF072E1E);    // Dark night green
  static const Color primaryLight = Color(0xFF198754);   // Bright emerald
  static const Color accentGold = Color(0xFFD4AF37);     // Royal gold
  static const Color accentGoldLight = Color(0xFFFDE68A); // Soft gold
  static const Color warmAmber = Color(0xFFF59E0B);

  // ألوان الخلفيات
  static const Color backgroundLight = Color(0xFFF8FAF9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  static const Color backgroundDark = Color(0xFF0B1411);
  static const Color surfaceDark = Color(0xFF13221C);
  static const Color cardDark = Color(0xFF182D25);

  // النصوص
  static const Color textPrimaryLight = Color(0xFF1C2D27);
  static const Color textSecondaryLight = Color(0xFF5A7268);
  static const Color textPrimaryDark = Color(0xFFE8F5E9);
  static const Color textSecondaryDark = Color(0xFFA5D6A7);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryEmerald,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryEmerald,
        secondary: AppColors.accentGold,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
      ),
      fontFamily: 'Amiri',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryEmerald,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Amiri',
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardLight,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.accentGold.withOpacity(0.15)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryEmerald,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryEmerald,
        secondary: AppColors.accentGold,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
      ),
      fontFamily: 'Amiri',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.accentGold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.accentGold,
          fontFamily: 'Amiri',
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardDark,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.accentGold.withOpacity(0.2)),
        ),
      ),
    );
  }
}
