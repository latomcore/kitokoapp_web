import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Secure Storage Service
/// 
/// Provides encrypted storage for sensitive data like API credentials and keys.
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences
/// - Web: Encrypted localStorage (using Web Crypto API)
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // Configure secure storage with appropriate options
  // For web, use default options (WebOptions are handled automatically)
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for stored values
  static const String _apiUsernameKey = 'api_username';
  static const String _apiPasswordKey = 'api_password';
  static const String _publicKeyKey = 'public_key';
  static const String _publicKeyTimestampKey = 'public_key_timestamp';

  /// Store API username securely
  Future<void> setApiUsername(String username) async {
    try {
      await _storage.write(key: _apiUsernameKey, value: username);
      if (kDebugMode) {
        debugPrint('✅ API username stored securely');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to store API username: $e');
      }
      rethrow;
    }
  }

  /// Get API username from secure storage
  Future<String?> getApiUsername() async {
    try {
      return await _storage.read(key: _apiUsernameKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to read API username: $e');
      }
      return null;
    }
  }

  /// Store API password securely
  Future<void> setApiPassword(String password) async {
    try {
      await _storage.write(key: _apiPasswordKey, value: password);
      if (kDebugMode) {
        debugPrint('✅ API password stored securely');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to store API password: $e');
      }
      rethrow;
    }
  }

  /// Get API password from secure storage
  Future<String?> getApiPassword() async {
    try {
      return await _storage.read(key: _apiPasswordKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to read API password: $e');
      }
      return null;
    }
  }

  /// Store PUBLIC_KEY securely with timestamp
  Future<void> setPublicKey(String publicKey) async {
    try {
      await _storage.write(key: _publicKeyKey, value: publicKey);
      // Store timestamp for expiration checking (12 hours = 43200000 milliseconds)
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await _storage.write(key: _publicKeyTimestampKey, value: timestamp);
      if (kDebugMode) {
        debugPrint('✅ PUBLIC_KEY stored securely (${publicKey.length} chars)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to store PUBLIC_KEY: $e');
      }
      rethrow;
    }
  }

  /// Get PUBLIC_KEY from secure storage
  Future<String?> getPublicKey() async {
    try {
      return await _storage.read(key: _publicKeyKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to read PUBLIC_KEY: $e');
      }
      return null;
    }
  }

  /// Check if PUBLIC_KEY is expired (older than 12 hours)
  Future<bool> isPublicKeyExpired() async {
    try {
      final timestampStr = await _storage.read(key: _publicKeyTimestampKey);
      if (timestampStr == null) {
        return true; // No timestamp means expired
      }

      final timestamp = int.tryParse(timestampStr);
      if (timestamp == null) {
        return true; // Invalid timestamp means expired
      }

      final storedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(storedTime);

      // Check if more than 12 hours have passed
      final isExpired = difference.inHours >= 12;

      if (kDebugMode) {
        debugPrint('🔍 PUBLIC_KEY age: ${difference.inHours} hours (expired: $isExpired)');
      }

      return isExpired;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to check PUBLIC_KEY expiration: $e');
      }
      return true; // On error, assume expired
    }
  }

  /// Clear all stored credentials (for logout/security)
  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _apiUsernameKey);
      await _storage.delete(key: _apiPasswordKey);
      await _storage.delete(key: _publicKeyKey);
      await _storage.delete(key: _publicKeyTimestampKey);
      if (kDebugMode) {
        debugPrint('✅ All secure storage cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear secure storage: $e');
      }
    }
  }

  /// Clear only PUBLIC_KEY (for refresh)
  Future<void> clearPublicKey() async {
    try {
      await _storage.delete(key: _publicKeyKey);
      await _storage.delete(key: _publicKeyTimestampKey);
      if (kDebugMode) {
        debugPrint('✅ PUBLIC_KEY cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear PUBLIC_KEY: $e');
      }
    }
  }
}

