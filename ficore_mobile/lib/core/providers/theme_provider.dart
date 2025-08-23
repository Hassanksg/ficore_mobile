import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/storage_service.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  
  ThemeProvider() {
    _loadThemeMode();
  }

  AppThemeMode get appThemeMode => _themeMode;
  
  ThemeMode get themeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  bool get isLightMode => _themeMode == AppThemeMode.light;
  bool get isDarkMode => _themeMode == AppThemeMode.dark;
  bool get isSystemMode => _themeMode == AppThemeMode.system;

  // Load saved theme preference
  Future<void> _loadThemeMode() async {
    try {
      final savedTheme = await StorageService.getThemeMode();
      _themeMode = _parseThemeMode(savedTheme);
      _updateSystemUI();
      notifyListeners();
    } catch (e) {
      // Use system default if loading fails
      _themeMode = AppThemeMode.system;
      _updateSystemUI();
      notifyListeners();
    }
  }

  // Parse theme mode from string
  AppThemeMode _parseThemeMode(String themeString) {
    switch (themeString.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  // Convert theme mode to string
  String _themeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  // Change theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (mode == _themeMode) return;

    _themeMode = mode;
    
    // Save to storage
    await StorageService.saveThemeMode(_themeToString(mode));
    
    // Update system UI
    _updateSystemUI();
    
    notifyListeners();
  }

  // Toggle between light and dark (ignoring system)
  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  // Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(AppThemeMode.light);
  }

  // Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(AppThemeMode.dark);
  }

  // Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(AppThemeMode.system);
  }

  // Update system UI overlay style based on current theme
  void _updateSystemUI() {
    // Get the current brightness from the system
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    
    Brightness effectiveBrightness;
    switch (_themeMode) {
      case AppThemeMode.light:
        effectiveBrightness = Brightness.light;
        break;
      case AppThemeMode.dark:
        effectiveBrightness = Brightness.dark;
        break;
      case AppThemeMode.system:
        effectiveBrightness = brightness;
        break;
    }

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: effectiveBrightness == Brightness.light 
            ? Brightness.dark 
            : Brightness.light,
        systemNavigationBarColor: effectiveBrightness == Brightness.light 
            ? Colors.white 
            : Colors.black,
        systemNavigationBarIconBrightness: effectiveBrightness == Brightness.light 
            ? Brightness.dark 
            : Brightness.light,
      ),
    );
  }

  // Get theme mode display name
  String getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  // Get current theme mode display name
  String get currentThemeModeDisplayName {
    return getThemeModeDisplayName(_themeMode);
  }

  // Get theme mode icon
  IconData getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  // Get current theme mode icon
  IconData get currentThemeModeIcon {
    return getThemeModeIcon(_themeMode);
  }

  // Get all available theme modes
  List<AppThemeMode> get availableThemeModes {
    return AppThemeMode.values;
  }

  // Check if current theme is effective dark mode
  bool isEffectiveDarkMode(BuildContext context) {
    switch (_themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return Theme.of(context).brightness == Brightness.dark;
    }
  }

  // Check if current theme is effective light mode
  bool isEffectiveLightMode(BuildContext context) {
    return !isEffectiveDarkMode(context);
  }

  // Reset to system default
  Future<void> resetToDefault() async {
    await setThemeMode(AppThemeMode.system);
  }

  // Update system UI when app lifecycle changes
  void updateSystemUIOnLifecycleChange() {
    _updateSystemUI();
  }
}