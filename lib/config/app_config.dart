import 'package:flutter/foundation.dart';
import 'package:kitokopay/service/secure_storage_service.dart';

/// App Configuration
/// 
/// This class provides centralized configuration management using Flutter's
/// --dart-define flags, which work consistently across all platforms.
/// 
/// Usage:
///   flutter run --dart-define=ELMS_BASE_URL=https://kitokoapp.com/elms --dart-define=API_USERNAME=user
/// 
/// Or set in your IDE run configuration with:
///   --dart-define=ELMS_BASE_URL=https://kitokoapp.com/elms
///   --dart-define=API_USERNAME=KL0Qw0Vdd
///   --dart-define=API_PASSWORD=Db0wU8eRzU3Yz0P3zJ
///   --dart-define=PLATFORM=WEB
///   --dart-define=DEVICE=WEB
///   --dart-define=DEFAULT_LAT=0.200
///   --dart-define=DEFAULT_LON=-1.01
///   --dart-define=PUBLIC_KEY=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0OTq4FBkCO/5kZbBgt+7tHUKmqa6NSvzGnvo8Pia2C7moYDF77TGNcMk5Q5bYjE91QCauAYWxse2thARA1X6FjJz/jeVfYpcV43uuKd8FDaI7P7ah4A+WO4CTwRu95x2a5Hzg0y3qWsxuuBtBeV66uWzKtKcWObPwsblPjfgWkpAxhaIdWhnAk1cXDrukGLrzRIhdY+m3M6yyoW9E+htP9oSkhBF39TxjNtGM0vTSA/w9rVv3x1DGCc7hlvo8DOaj4aG60pdsA7VkVeBnEsXS/lba5dVRFCUHAlMUQfKVx7pZJ9fuHP9IZIfRE0wTPPZwqJSlU8/YQ0ARa5ic5NLjQIDAQAB
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // API Configuration
  static String get elmsBaseUrl {
    const value = String.fromEnvironment('ELMS_BASE_URL', defaultValue: '');
    if (value.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ ELMS_BASE_URL not found in --dart-define, using default: https://kitokoapp.com/elms');
      }
      return 'https://kitokoapp.com/elms';
    }
    if (kDebugMode) {
      debugPrint('✅ ELMS_BASE_URL loaded from --dart-define: $value');
    }
    return value;
  }

  /// Get API username from secure storage or --dart-define
  static Future<String> getApiUsername() async {
    try {
      final secureStorage = SecureStorageService();
      final username = await secureStorage.getApiUsername();
      
      if (username != null && username.isNotEmpty) {
        return username;
      }
      
      // Fallback to --dart-define
      const value = String.fromEnvironment('API_USERNAME', defaultValue: '');
      return value.isEmpty ? 'L@T0wU8eR' : value;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting API username: $e');
      }
      const value = String.fromEnvironment('API_USERNAME', defaultValue: '');
      return value.isEmpty ? 'L@T0wU8eR' : value;
    }
  }
  
  /// Get API password from secure storage or --dart-define
  static Future<String> getApiPassword() async {
    try {
      final secureStorage = SecureStorageService();
      final password = await secureStorage.getApiPassword();
      
      if (password != null && password.isNotEmpty) {
        return password;
      }
      
      // Fallback to --dart-define
      const value = String.fromEnvironment('API_PASSWORD', defaultValue: '');
      return value.isEmpty ? 'TGF0MHdDb1IzU3Yz' : value;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting API password: $e');
      }
      const value = String.fromEnvironment('API_PASSWORD', defaultValue: '');
      return value.isEmpty ? 'TGF0MHdDb1IzU3Yz' : value;
    }
  }
  
  // Synchronous getters for backward compatibility (deprecated)
  @Deprecated('Use getApiUsername() async method instead')
  static String get apiUsername {
    const value = String.fromEnvironment('API_USERNAME', defaultValue: '');
    return value.isEmpty ? 'L@T0wU8eR' : value;
  }

  @Deprecated('Use getApiPassword() async method instead')
  static String get apiPassword {
    const value = String.fromEnvironment('API_PASSWORD', defaultValue: '');
    return value.isEmpty ? 'TGF0MHdDb1IzU3Yz' : value;
  }

  // Platform Configuration
  static String get platform {
    const value = String.fromEnvironment('PLATFORM', defaultValue: '');
    return value.isEmpty ? 'WEB' : value;
  }

  static String get device {
    const value = String.fromEnvironment('DEVICE', defaultValue: '');
    return value.isEmpty ? 'WEB' : value;
  }

  static String get defaultLat {
    const value = String.fromEnvironment('DEFAULT_LAT', defaultValue: '');
    return value.isEmpty ? '0.200' : value;
  }

  static String get defaultLon {
    const value = String.fromEnvironment('DEFAULT_LON', defaultValue: '');
    return value.isEmpty ? '-1.01' : value;
  }

  // Security
  /// Get PUBLIC_KEY from secure storage (dynamically fetched from server)
  /// 
  /// Returns cached PUBLIC_KEY if available, otherwise returns fallback.
  /// PUBLIC_KEY is fetched during splash screen initialization.
  static Future<String> getPublicKey() async {
    try {
      final secureStorage = SecureStorageService();
      final publicKey = await secureStorage.getPublicKey();
      
      if (publicKey != null && publicKey.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('✅ PUBLIC_KEY loaded from secure storage (${publicKey.length} chars)');
        }
        return publicKey;
      }
      
      // Fallback to --dart-define if secure storage is empty
      const value = String.fromEnvironment('PUBLIC_KEY', defaultValue: '');
      if (value.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ Using PUBLIC_KEY from --dart-define (fallback)');
        }
        return value;
      }
      
      if (kDebugMode) {
        debugPrint('⚠️ PUBLIC_KEY not found in secure storage or --dart-define');
      }
      return 'No Public Key Found';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting PUBLIC_KEY: $e');
      }
      return 'No Public Key Found';
    }
  }
  
  /// Synchronous getter for PUBLIC_KEY (for backward compatibility)
  /// 
  /// Note: This will return 'No Public Key Found' if called before
  /// PUBLIC_KEY is fetched. Use getPublicKey() async method instead.
  @Deprecated('Use getPublicKey() async method instead')
  static String get publicKey => 'No Public Key Found';

  // API Endpoints (derived from base URL)
  static String get loadApiEndPoint => '$elmsBaseUrl/load';
  static String get authApiEndPoint => '$elmsBaseUrl/auth';
  static String get coreApiEndPoint => '$elmsBaseUrl/core';

  /// Validate that all required configuration is present
  static Future<bool> validate() async {
    final issues = <String>[];
    
    if (elmsBaseUrl == 'https://kitokoapp.com/elms') {
      issues.add('ELMS_BASE_URL is using default value');
    }
    
    // Note: Can't check async publicKey in sync validate method
    // This is checked during app initialization
    
    if (issues.isNotEmpty && kDebugMode) {
      debugPrint('⚠️ Configuration Issues:');
      for (final issue in issues) {
        debugPrint('  - $issue');
      }
      debugPrint('💡 Tip: Use --dart-define flags to set configuration values');
    }
    
    return issues.isEmpty;
  }

  /// Print current configuration (for debugging, excludes sensitive data)
  static Future<void> printConfig() async {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📋 APP CONFIGURATION');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('ELMS_BASE_URL: $elmsBaseUrl');
      final username = await getApiUsername();
      final password = await getApiPassword();
      debugPrint('API_USERNAME: $username');
      debugPrint('API_PASSWORD: ***');
      debugPrint('PLATFORM: $platform');
      debugPrint('DEVICE: $device');
      debugPrint('DEFAULT_LAT: $defaultLat');
      debugPrint('DEFAULT_LON: $defaultLon');
      final publicKey = await getPublicKey();
      debugPrint('PUBLIC_KEY: ${publicKey != 'No Public Key Found' ? 'Found (${publicKey.length} chars)' : 'NOT FOUND'}');
      debugPrint('═══════════════════════════════════════════════════════════');
    }
  }
}

