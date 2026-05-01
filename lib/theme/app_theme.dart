import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.neonPurple,
        surface: AppColors.darkSidebar,
        error: AppColors.red,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
      dividerColor: Colors.white10,
      cardColor: AppColors.darkSidebar,
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.neonPurple,
        surface: AppColors.lightSidebar,
        error: AppColors.red,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: AppColors.lightText,
        displayColor: AppColors.lightText,
      ),
      dividerColor: Colors.black12,
      cardColor: AppColors.lightSidebar,
      useMaterial3: true,
    );
  }
}
