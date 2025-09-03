import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.basePurple,
        brightness: Brightness.light,
        primary: AppColors.basePurple,
        secondary: AppColors.continueGreen,
        tertiary: AppColors.congratulationsYellow,
        surface: AppColors.neutralLight,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.basePurple,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.basePurple,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.basePurple,
        foregroundColor: AppColors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.neutralDark,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.neutralDark,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.neutralDark,
        ),
        bodyMedium: TextStyle(
          color: AppColors.neutralDark,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.neutralLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.basePurple,
        brightness: Brightness.dark,
        primary: AppColors.basePurple,
        secondary: AppColors.continueGreen,
        tertiary: AppColors.congratulationsYellow,
        surface: AppColors.neutralDark,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutralDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.basePurple,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.basePurple,
        foregroundColor: AppColors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.neutralLight,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.neutralLight,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.neutralLight,
        ),
        bodyMedium: TextStyle(
          color: AppColors.neutralLight,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.neutralDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}