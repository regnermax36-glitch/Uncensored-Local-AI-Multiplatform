import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  final _box = Hive.box('settings');
  final _key = 'isDarkMode';

  ThemeMode get themeMode => _loadTheme() ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkMode => _loadTheme();

  bool _loadTheme() => _box.get(_key, defaultValue: true);
  void _saveTheme(bool isDark) => _box.put(_key, isDark);

  void toggleTheme() {
    Get.changeThemeMode(_loadTheme() ? ThemeMode.light : ThemeMode.dark);
    _saveTheme(!_loadTheme());
    update();
  }
}
