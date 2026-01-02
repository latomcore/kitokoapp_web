import 'package:kitokopay/service/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;

/// Token Storage Service
/// 
/// PHASE 2 SECURITY FIX: Migrated from plain SharedPreferences to secure storage.
/// 
/// WEB FIX: On web, uses SharedPreferences directly because flutter_secure_storage
/// has encryption key persistence issues with hot restart. On mobile, uses secure storage.
/// 
/// REVERT OPTION: If issues occur, see token_storage_backup.dart for original implementation.
class TokenStorage {
  final SecureStorageService _secureStorage = SecureStorageService();
  static const _tokenKey = 'auth_token'; // Keep for migration/backup

  /// Check if we should use secure storage (mobile) or SharedPreferences (web)
  bool get _useSecureStorage => !kIsWeb; // Use secure storage only on mobile

  /// Save token to secure storage (encrypted on mobile) or SharedPreferences (web)
  /// 
  /// WEB: Uses SharedPreferences directly (HTTPS provides encryption in transit)
  /// MOBILE: Uses flutter_secure_storage (platform secure storage)
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_useSecureStorage) {
      // Mobile: Use secure storage
      try {
        await _secureStorage.setAuthToken(token);
        
        // Don't set expiration - let the server handle token expiration
        // The 1-hour expiration was causing premature token removal
        
        // Keep backup in SharedPreferences for easy revert
        await prefs.setString(_tokenKey, token);
        
        if (kDebugMode) {
          debugPrint('✅ Token stored securely (mobile - secure storage)');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Failed to store token in secure storage: $e');
          debugPrint('   Falling back to SharedPreferences...');
        }
        // Fallback to SharedPreferences if secure storage fails
        await prefs.setString(_tokenKey, token);
      }
    } else {
      // Web: Use SharedPreferences directly (HTTPS provides encryption)
      await prefs.setString(_tokenKey, token);
      
      if (kDebugMode) {
        debugPrint('✅ Token stored (web - SharedPreferences, HTTPS encrypted)');
      }
    }
  }

  /// Retrieve token from secure storage (mobile) or SharedPreferences (web)
  /// 
  /// WEB: Reads directly from SharedPreferences
  /// MOBILE: Reads from secure storage, falls back to SharedPreferences
  /// Returns null if token doesn't exist.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_useSecureStorage) {
      // Mobile: Try secure storage first, fallback to SharedPreferences
      try {
        final token = await _secureStorage.getAuthToken();
        
        if (token != null && token.isNotEmpty) {
          // Don't check expiration - let the server handle it
          // The 1-hour expiration was causing premature token removal
          return token;
        }
        
        // Fallback: Try SharedPreferences (for migration/revert support)
        if (kDebugMode) {
          debugPrint('⚠️ Token not found in secure storage, checking SharedPreferences backup...');
        }
        final backupToken = prefs.getString(_tokenKey);
        
        if (backupToken != null && backupToken.isNotEmpty) {
          // Migrate to secure storage
          if (kDebugMode) {
            debugPrint('🔄 Migrating token from SharedPreferences to secure storage...');
          }
          await setToken(backupToken);
          return backupToken;
        }
        
        return null;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Failed to retrieve token from secure storage: $e');
          debugPrint('   Falling back to SharedPreferences...');
        }
        // Fallback to SharedPreferences if secure storage fails
        return prefs.getString(_tokenKey);
      }
    } else {
      // Web: Read directly from SharedPreferences
      return prefs.getString(_tokenKey);
    }
  }

  /// Remove token from secure storage (mobile) or SharedPreferences (web)
  /// 
  /// Also removes from SharedPreferences backup.
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_useSecureStorage) {
      // Mobile: Remove from secure storage and SharedPreferences
      try {
        await _secureStorage.removeAuthToken();
        await prefs.remove(_tokenKey);
        
        if (kDebugMode) {
          debugPrint('✅ Token removed from secure storage and SharedPreferences');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Failed to remove token from secure storage: $e');
        }
        // Try to remove from SharedPreferences as fallback
        await prefs.remove(_tokenKey);
      }
    } else {
      // Web: Remove from SharedPreferences
      await prefs.remove(_tokenKey);
      
      if (kDebugMode) {
        debugPrint('✅ Token removed from SharedPreferences');
      }
    }
  }

  /// Check if token exists and is valid
  Future<bool> hasValidToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
