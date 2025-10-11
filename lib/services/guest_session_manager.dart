import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'tmdb_api_service.dart';

class GuestSessionManager {
  static const String _guestSessionKey = 'guest_session';
  static const String _sessionExpiryKey = 'session_expiry';

  static String? _guestSessionId;
  static DateTime? _sessionExpiry;

  // Get current guest session ID
  static String? get guestSessionId => _guestSessionId;

  // Check if session is valid
  static bool get isSessionValid {
    if (_guestSessionId == null || _sessionExpiry == null) {
      return false;
    }
    return DateTime.now().isBefore(_sessionExpiry!);
  }

  // Create a new guest session
  static Future<String?> createGuestSession() async {
    try {
      final response = await TMDBAPIService.createGuestSession();

      if (response['success'] == true) {
        _guestSessionId = response['guest_session_id'];
        _sessionExpiry = DateTime.now().add(const Duration(hours: 24));

        // Save to shared preferences
        await _saveSessionToPrefs();

        return _guestSessionId;
      }
    } catch (e) {
      print('Error creating guest session: $e');
    }
    return null;
  }

  // Load session from shared preferences
  static Future<void> loadSessionFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString(_guestSessionKey);
      final expiryString = prefs.getString(_sessionExpiryKey);

      if (sessionId != null && expiryString != null) {
        _guestSessionId = sessionId;
        _sessionExpiry = DateTime.parse(expiryString);

        // Check if session is still valid
        if (!isSessionValid) {
          await clearSession();
        }
      }
    } catch (e) {
      print('Error loading session from prefs: $e');
    }
  }

  // Save session to shared preferences
  static Future<void> _saveSessionToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_guestSessionKey, _guestSessionId!);
      await prefs.setString(
        _sessionExpiryKey,
        _sessionExpiry!.toIso8601String(),
      );
    } catch (e) {
      print('Error saving session to prefs: $e');
    }
  }

  // Clear session
  static Future<void> clearSession() async {
    _guestSessionId = null;
    _sessionExpiry = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestSessionKey);
      await prefs.remove(_sessionExpiryKey);
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  // Get or create session
  static Future<String?> getOrCreateSession() async {
    // Load existing session first
    await loadSessionFromPrefs();

    // If session is valid, return it
    if (isSessionValid) {
      return _guestSessionId;
    }

    // Otherwise, create a new one
    return await createGuestSession();
  }
}
