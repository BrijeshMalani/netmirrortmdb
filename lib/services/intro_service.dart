import 'package:shared_preferences/shared_preferences.dart';

class IntroService {
  static const String _introCompletedKey = 'intro_completed';
  static const String _selectedLanguageKey = 'selected_language';
  static const String _selectedCountryKey = 'selected_country';

  /// Check if intro has been completed
  static Future<bool> isIntroCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_introCompletedKey) ?? false;
  }

  /// Mark intro as completed
  static Future<void> markIntroCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introCompletedKey, true);
  }

  /// Get selected language
  static Future<String> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedLanguageKey) ?? 'en';
  }

  /// Set selected language
  static Future<void> setSelectedLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLanguageKey, language);
  }

  /// Get selected country
  static Future<String> getSelectedCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedCountryKey) ?? 'US';
  }

  /// Set selected country
  static Future<void> setSelectedCountry(String country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCountryKey, country);
  }

  /// Reset intro (for testing purposes)
  static Future<void> resetIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_introCompletedKey);
    await prefs.remove(_selectedLanguageKey);
    await prefs.remove(_selectedCountryKey);
  }
}
