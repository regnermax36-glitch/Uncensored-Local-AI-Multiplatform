import 'package:flutter/material.dart';

extension ThemeExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg => isDark ? AppColors.darkBg : AppColors.lightBg;
  Color get bgSidebar => isDark ? AppColors.darkSidebar : AppColors.lightSidebar;
  Color get glass => isDark ? AppColors.glassDark : AppColors.glassLight;
  Color get glassBorder => isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
  
  Color get text => isDark ? AppColors.darkText : AppColors.lightText;
  Color get textM => isDark ? AppColors.darkTextM : AppColors.lightTextM;
  Color get textD => isDark ? AppColors.darkTextD : AppColors.lightTextD;

  Color get neonBlue => AppColors.neonBlue;
  Color get neonPurple => AppColors.neonPurple;
  Color get neonCyan => AppColors.neonCyan;
}

class AppColors {
  AppColors._();

  // 2089 Neon Palette
  static const neonBlue   = Color(0xFF00D2FF);
  static const neonPurple = Color(0xFF9B51E0);
  static const neonCyan   = Color(0xFF00FFF2);
  static const neonPink   = Color(0xFFFF00CC);
  static const accent     = Color(0xFF007AFF);
  static const green      = Color(0xFF34C759);
  static const red        = Color(0xFFFF3B30);
  static const orange     = Color(0xFFFF9500);

  // Dark Theme (Futuristic Deep Black)
  static const darkBg      = Color(0xFF020408);
  static const darkSidebar = Color(0xFF0A0F14);
  static const darkText    = Color(0xFFE0E6ED);
  static const darkTextM   = Color(0x99A0AEC0);
  static const darkTextD   = Color(0x4D718096);

  // Light Theme (Clean Glass)
  static const lightBg      = Color(0xFFF7FAFC);
  static const lightSidebar = Color(0xFFFFFFFF);
  static const lightText    = Color(0xFF1A202C);
  static const lightTextM   = Color(0x994A5568);
  static const lightTextD   = Color(0x4DA0AEC0);

  // Neural Glassmorphism
  static const glassDark        = Color(0xCC0A0F14);
  static const glassLight       = Color(0xCCFFFFFF);
  static const glassBorderDark  = Color(0x1A00D2FF);
  static const glassBorderLight = Color(0x1A000000);

  // Gradients (Neural Matrix)
  static const neuralGradient = LinearGradient(
    colors: [neonBlue, neonPurple, neonPink, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final accentGradient = LinearGradient(
    colors: [accent, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
