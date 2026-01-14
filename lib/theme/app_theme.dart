import 'package:flutter/material.dart';

/// Military green color palette - Vietnam People's Army theme
class AppColors {
  // Primary Military Green Backgrounds
  static const Color bgPrimary = Color(0xFF1A2E1A);      // Dark military green
  static const Color bgSecondary = Color(0xFF2C3E2D);   // Medium olive green
  static const Color bgTertiary = Color(0xFF3D5240);    // Lighter olive green
  static const Color bgCard = Color(0xE62C3E2D);        // Card with transparency

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5DC);   // Beige/Cream
  static const Color textSecondary = Color(0xFFA8B89A); // Muted sage green
  static const Color textMuted = Color(0xFF6B7C5F);     // Darker muted green
  static const Color textAccent = Color(0xFFC9A227);    // Military gold/khaki

  // Borders
  static const Color borderPrimary = Color(0xFF3D5240);  // Olive border
  static const Color borderSecondary = Color(0xFF4A6350); // Lighter olive
  static const Color borderAccent = Color(0xFFC9A227);   // Gold accent

  // Accent colors - Military Gold
  static const Color accentPrimary = Color(0xFFC9A227);  // Military gold
  static const Color accentHover = Color(0xFFD4B13A);    // Lighter gold
  static const Color accentDark = Color(0xFFA68A1F);     // Darker gold

  // Status colors
  static const Color danger = Color(0xFF8B2500);         // Dark red
  static const Color dangerBg = Color(0x668B2500);       // 40% opacity
  static const Color dangerBorder = Color(0x998B2500);   // 60% opacity
  static const Color dangerText = Color(0xFFFFB4A1);     // Light salmon

  // Success
  static const Color success = Color(0xFF4A7C4E);        // Military green
  static const Color successBg = Color(0x664A7C4E);      // 40% opacity

  // Others
  static const Color transparent = Colors.transparent;
  static const Color overlay = Color(0x99000000);        // 60% black
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Star color
  static const Color starGold = Color(0xFFDAA520);
}

/// App theme configuration
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.accentPrimary,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgSecondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderPrimary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentPrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: AppColors.bgPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentPrimary,
        secondary: AppColors.accentHover,
        surface: AppColors.bgSecondary,
        error: AppColors.danger,
      ),
    );
  }
}
