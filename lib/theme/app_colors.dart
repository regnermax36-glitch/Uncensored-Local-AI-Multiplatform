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
}

class AppColors {
  AppColors._();

  static const accent = Color(0xFF007AFF);
  static const purple = Color(0xFF9B51E0);
  static const green  = Color(0xFF34C759);
  static const red    = Color(0xFFFF3B30);
  static const orange = Color(0xFFFF9500);

  static const darkBg      = Color(0xFF000000);
  static const darkSidebar = Color(0xFF1C1C1E);
  static const darkText    = Color(0xFFFFFFFF);
  static const darkTextM   = Color(0x99EBEBF5);
  static const darkTextD   = Color(0x4DEBEBF5);

  static const lightBg      = Color(0xFFF2F2F7);
  static const lightSidebar = Color(0xFFFFFFFF);
  static const lightText    = Color(0xFF000000);
  static const lightTextM   = Color(0x993C3C43);
  static const lightTextD   = Color(0x4D3C3C43);

  static const glassDark        = Color(0x991C1C1E);
  static const glassLight       = Color(0x99FFFFFF);
  static const glassBorderDark  = Color(0x33FFFFFF);
  static const glassBorderLight = Color(0x33000000);

  static const siriGradient = LinearGradient(
    colors: [Color(0xFF4285F4), Color(0xFF9B51E0), Color(0xFFEB5757), Color(0xFFF2C94C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final accentGradient = LinearGradient(
    colors: [accent, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
