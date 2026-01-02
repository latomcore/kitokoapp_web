import 'package:shared_preferences/shared_preferences.dart';

/// Backup Token Storage Implementation
/// 
/// This is the ORIGINAL implementation using SharedPreferences.
/// Keep this file as a backup in case we need to revert.
/// 
/// To revert: Rename this file to token_storage.dart and restore the original.
class TokenStorageBackup {
  static const _tokenKey = 'auth_token'; // Key to store the token

  // Save token to shared preferences
  Future<void> setToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Retrieve token from shared preferences
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Remove token from shared preferences (e.g., on logout)
  Future<void> removeToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

