// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color greenDark    = Color(0xFF0D2B1A);
  static const Color greenMid     = Color(0xFF1A4A2E);
  static const Color greenBright  = Color(0xFF2D9E5F);
  static const Color greenAccent  = Color(0xFF56E39F);
  static const Color greenDeep    = Color(0xFF16A461);
  static const Color gold         = Color(0xFFFFE566);
  static const Color goldDark     = Color(0xFFFF9900);
  static const Color badgeRed     = Color(0xFFFF3B3B);
  static const Color overlay45    = Color(0x73000000);
  static const Color borderWhite  = Color(0x33FFFFFF);

  // Minijuego colores
  static const Color starGold     = Color(0xFFFFD700);
  static const Color correct      = Color(0xFF4CAF50);
  static const Color wrong        = Color(0xFFF44336);
  static const Color cardBack     = Color(0xFF1B4332);
  static const Color cardFront    = Color(0xFF2D9E5F);
}

abstract class AppTheme {
  static ThemeData get theme => ThemeData(
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: AppColors.greenDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.greenAccent,
          secondary: AppColors.gold,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.greenAccent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      );
}
