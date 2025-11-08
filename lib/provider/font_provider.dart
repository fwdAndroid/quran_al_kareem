import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSettingsProvider extends ChangeNotifier {
  String _arabicFontFamily = 'Tahoma'; // default
  double _fontSize = 14.0; // default

  String get arabicFontFamily => _arabicFontFamily;
  double get fontSize => _fontSize;

  FontSettingsProvider() {
    _loadFontSettings();
  }

  Future<void> _loadFontSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontFamily = prefs.getString('arabicFontFamily') ?? 'Tahoma';
    _fontSize = prefs.getDouble('fontSize') ?? 18.0;
    notifyListeners();
  }

  Future<void> updateFontFamily(String font) async {
    _arabicFontFamily = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('arabicFontFamily', font);
    notifyListeners();
  }

  Future<void> updateFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    notifyListeners();
  }

  /// 🔁 Reset to default and save in SharedPreferences
  Future<void> resetToDefault() async {
    _arabicFontFamily = 'Tahoma';
    _fontSize = 18.0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('arabicFontFamily', _arabicFontFamily);
    await prefs.setDouble('fontSize', _fontSize);

    notifyListeners();
  }
}
