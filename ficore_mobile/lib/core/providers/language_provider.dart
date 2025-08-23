import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  
  LanguageProvider() {
    _loadLanguage();
  }

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  
  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isHausa => _currentLocale.languageCode == 'ha';

  // Load saved language preference
  Future<void> _loadLanguage() async {
    try {
      final savedLanguage = await StorageService.getLanguage();
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    } catch (e) {
      // Use default language if loading fails
      _currentLocale = const Locale(AppConfig.defaultLanguage);
      notifyListeners();
    }
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;
    
    // Validate language code
    if (!['en', 'ha'].contains(languageCode)) {
      languageCode = AppConfig.defaultLanguage;
    }

    _currentLocale = Locale(languageCode);
    
    // Save to storage
    await StorageService.saveLanguage(languageCode);
    
    notifyListeners();
  }

  // Toggle between English and Hausa
  Future<void> toggleLanguage() async {
    final newLanguage = isEnglish ? 'ha' : 'en';
    await changeLanguage(newLanguage);
  }

  // Get language display name
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ha':
        return 'Hausa';
      default:
        return 'English';
    }
  }

  // Get current language display name
  String get currentLanguageDisplayName {
    return getLanguageDisplayName(_currentLocale.languageCode);
  }

  // Get available languages
  List<Map<String, String>> get availableLanguages {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'ha', 'name': 'Hausa', 'nativeName': 'Hausa'},
    ];
  }

  // Check if a language is supported
  bool isLanguageSupported(String languageCode) {
    return ['en', 'ha'].contains(languageCode);
  }

  // Get language flag emoji
  String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸'; // US flag for English
      case 'ha':
        return '🇳🇬'; // Nigerian flag for Hausa
      default:
        return '🌐'; // Globe for unknown
    }
  }

  // Get current language flag
  String get currentLanguageFlag {
    return getLanguageFlag(_currentLocale.languageCode);
  }

  // Reset to default language
  Future<void> resetToDefault() async {
    await changeLanguage(AppConfig.defaultLanguage);
  }
}