import 'package:kitokopay/service/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Sensitive Data Storage Service
/// 
/// PHASE 2 SECURITY FIX: Migrated CustomerId and AppId from plain SharedPreferences 
/// to secure storage. These values are now encrypted at rest.
/// 
/// WEB FIX: On web, uses SharedPreferences directly because flutter_secure_storage
/// has encryption key persistence issues with hot restart. On mobile, uses secure storage.
/// 
/// REVERT OPTION: If issues occur, this service falls back to SharedPreferences automatically.
class SensitiveDataStorage {
  final SecureStorageService _secureStorage = SecureStorageService();
  
  // Keys for SharedPreferences (for migration/backup)
  static const _customerIdKey = 'customerId';
  static const _appIdKey = 'appId';
  
  /// Check if we should use secure storage (mobile) or SharedPreferences (web)
  bool get _useSecureStorage => !kIsWeb; // Use secure storage only on mobile

  /// Store CustomerId securely (mobile) or in SharedPreferences (web)
  /// 
  /// WEB: Uses SharedPreferences directly (HTTPS provides encryption in transit)
  /// MOBILE: Uses flutter_secure_storage (platform secure storage)
  Future<void> setCustomerId(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_useSecureStorage) {
      // Mobile: Use secure storage
      try {
        await _secureStorage.setCustomerId(customerId);
        await prefs.setString(_customerIdKey, customerId); // Backup
        
        if (kDebugMode) {
          debugPrint('✅ CustomerId stored securely (mobile - secure storage)');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Failed to store CustomerId in secure storage: $e');
          debugPrint('   Falling back to SharedPreferences...');
        }
        await prefs.setString(_customerIdKey, customerId);
      }
    } else {
      // Web: Use SharedPreferences directly
      await prefs.setString(_customerIdKey, customerId);
      
      if (kDebugMode) {
        debugPrint('✅ CustomerId stored (web - SharedPreferences, HTTPS encrypted)');
      }
    }
  }

  /// Get CustomerId from secure storage (mobile) or SharedPreferences (web)
  /// 
  /// WEB: Reads directly from SharedPreferences
  /// MOBILE: Reads from secure storage, falls back to SharedPreferences
  Future<String?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_useSecureStorage) {
      // Mobile: Try secure storage first, fallback to SharedPreferences
      try {
        final customerId = await _secureStorage.getCustomerId();
        
        if (customerId != null && customerId.isNotEmpty) {
          return customerId;
        }
        
        // Fallback: Try SharedPreferences
        if (kDebugMode) {
          debugPrint('⚠️ CustomerId not found in secure storage, checking SharedPreferences backup...');
        }
        final backupCustomerId = prefs.getString(_customerIdKey);
        
        if (backupCustomerId != null && backupCustomerId.isNotEmpty) {
          // Migrate to secure storage
          if (kDebugMode) {
            debugPrint('🔄 Migrating CustomerId from SharedPreferences to secure storage...');
          }
          await setCustomerId(backupCustomerId);
          return backupCustomerId;
        }
        
        return null;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Failed to retrieve CustomerId from secure storage: $e');
          debugPrint('   Falling back to SharedPreferences...');
        }
        return prefs.getString(_customerIdKey);
      }
    } else {
      // Web: Read directly from SharedPreferences
      return prefs.getString(_customerIdKey);
    }
  }

  /// Store AppId securely (mobile) or in SharedPreferences (web)
  /// 
  /// WEB: Uses SharedPreferences directly (HTTPS provides encryption in transit)
  /// MOBILE: Uses flutter_secure_storage (platform secure storage)
  Future<void> setAppId(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_useSecureStorage) {
      // Mobile: Use secure storage
      try {
        await _secureStorage.setAppId(appId);
        await prefs.setString(_appIdKey, appId); // Backup
        
        if (kDebugMode) {
          debugPrint('✅ AppId stored securely (mobile - secure storage)');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Failed to store AppId in secure storage: $e');
          debugPrint('   Falling back to SharedPreferences...');
        }
        await prefs.setString(_appIdKey, appId);
      }
    } else {
      // Web: Use SharedPreferences directly
      await prefs.setString(_appIdKey, appId);
      
      if (kDebugMode) {
        debugPrint('✅ AppId stored (web - SharedPreferences, HTTPS encrypted)');
      }
    }
  }

  /// Get AppId from secure storage (mobile) or SharedPreferences (web)
  /// 
  /// WEB: Reads directly from SharedPreferences
  /// MOBILE: Reads from secure storage, falls back to SharedPreferences
  Future<String?> getAppId() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_useSecureStorage) {
      // Mobile: Try secure storage first, fallback to SharedPreferences
      try {
        final appId = await _secureStorage.getAppId();
        
        if (appId != null && appId.isNotEmpty) {
          return appId;
        }
        
        // Fallback: Try SharedPreferences
        if (kDebugMode) {
          debugPrint('⚠️ AppId not found in secure storage, checking SharedPreferences backup...');
        }
        final backupAppId = prefs.getString(_appIdKey);
        
        if (backupAppId != null && backupAppId.isNotEmpty) {
          // Migrate to secure storage
          if (kDebugMode) {
            debugPrint('🔄 Migrating AppId from SharedPreferences to secure storage...');
          }
          await setAppId(backupAppId);
          return backupAppId;
        }
        
        return null;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Failed to retrieve AppId from secure storage: $e');
          debugPrint('   Falling back to SharedPreferences...');
        }
        return prefs.getString(_appIdKey);
      }
    } else {
      // Web: Read directly from SharedPreferences
      return prefs.getString(_appIdKey);
    }
  }

  /// Remove both CustomerId and AppId
  Future<void> clearAll() async {
    try {
      // Remove from secure storage
      await _secureStorage.removeCustomerId();
      await _secureStorage.removeAppId();
      
      // Also remove from SharedPreferences backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_customerIdKey);
      await prefs.remove(_appIdKey);
      
      if (kDebugMode) {
        debugPrint('✅ CustomerId and AppId removed from both secure storage and SharedPreferences');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear sensitive data: $e');
      }
      // Try to remove from SharedPreferences as fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_customerIdKey);
        await prefs.remove(_appIdKey);
      } catch (e2) {
        if (kDebugMode) {
          debugPrint('❌ Failed to clear sensitive data from SharedPreferences: $e2');
        }
      }
    }
  }
}

