import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemeModeKey = 'theme_mode_is_dark';

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier({SharedPreferences? prefs}) : _prefs = prefs {
    _loadFromPrefs();
  }

  SharedPreferences? _prefs;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadFromPrefs() {
    final isDark = _prefs?.getBool(_kThemeModeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_kThemeModeKey, isDark);
  }
}

class ThemeNotifierProvider extends InheritedNotifier<ThemeNotifier> {
  const ThemeNotifierProvider({
    super.key,
    required ThemeNotifier themeNotifier,
    required super.child,
  }) : super(notifier: themeNotifier);

  static ThemeNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeNotifierProvider>();
    assert(provider != null, 'No ThemeNotifierProvider found in context');
    return provider!.notifier!;
  }
}
