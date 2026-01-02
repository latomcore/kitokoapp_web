import 'dart:convert';
import 'package:kitokopay/service/token_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// Token Refresh Service
/// 
/// Handles token expiration checking and automatic refresh.
/// 
/// PHASE 3 SECURITY ENHANCEMENT: Token expiration management
class TokenRefreshService {
  // Cache last expiration check to reduce logging
  static String? _lastCheckedToken;
  static bool? _lastExpirationResult;
  static DateTime? _lastCheckTime;
  
  /// Check if token is expired
  /// 
  /// If token is a JWT, extracts expiration from payload.
  /// If not a JWT, assumes token is valid (backward compatibility).
  /// 
  /// Caches results to reduce excessive logging.
  static bool isTokenExpired(String? token) {
    if (token == null || token.isEmpty) {
      return true;
    }
    
    // Cache check: if same token checked recently, return cached result
    if (_lastCheckedToken == token && 
        _lastExpirationResult != null &&
        _lastCheckTime != null &&
        DateTime.now().difference(_lastCheckTime!) < const Duration(seconds: 5)) {
      return _lastExpirationResult!;
    }
    
    // Try to parse as JWT
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        // Decode JWT payload
        final payload = parts[1];
        
        // Add padding if needed for base64 decoding
        String normalized = payload;
        switch (payload.length % 4) {
          case 1:
            normalized += '===';
            break;
          case 2:
            normalized += '==';
            break;
          case 3:
            normalized += '=';
            break;
        }
        
        final decoded = utf8.decode(base64Decode(normalized));
        final json = jsonDecode(decoded);
        
        // Check expiration claim
        if (json['exp'] != null) {
          final expirationTimestamp = json['exp'] as int;
          final expiration = DateTime.fromMillisecondsSinceEpoch(expirationTimestamp * 1000);
          final isExpired = DateTime.now().isAfter(expiration);
          
          // Cache result
          _lastCheckedToken = token;
          _lastExpirationResult = isExpired;
          _lastCheckTime = DateTime.now();
          
          // Only log if expired (reduce log spam - don't log valid tokens)
          if (kDebugMode && isExpired) {
            debugPrint('🔍 Token expiration check: ❌ EXPIRED');
            debugPrint('   Expiration: $expiration');
            debugPrint('   Current: ${DateTime.now()}');
          }
          
          return isExpired;
        }
      }
    } catch (e) {
      // Not a JWT or parsing failed - assume valid for backward compatibility
      // Only log once per token to reduce spam
      if (kDebugMode && _lastCheckedToken != token) {
        debugPrint('⚠️ Token is not a JWT, assuming valid (backward compatibility)');
      }
      
      // Cache result
      _lastCheckedToken = token;
      _lastExpirationResult = false;
      _lastCheckTime = DateTime.now();
      
      return false;
    }
    
    // Not a JWT - assume valid (backward compatibility)
    // Cache result
    _lastCheckedToken = token;
    _lastExpirationResult = false;
    _lastCheckTime = DateTime.now();
    
    return false;
  }
  
  /// Get token expiration time (if JWT)
  /// 
  /// Returns expiration DateTime if token is JWT with exp claim, null otherwise.
  static DateTime? getTokenExpiration(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }
    
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        
        // Add padding if needed
        String normalized = payload;
        switch (payload.length % 4) {
          case 1:
            normalized += '===';
            break;
          case 2:
            normalized += '==';
            break;
          case 3:
            normalized += '=';
            break;
        }
        
        final decoded = utf8.decode(base64Decode(normalized));
        final json = jsonDecode(decoded);
        
        if (json['exp'] != null) {
          final expirationTimestamp = json['exp'] as int;
          return DateTime.fromMillisecondsSinceEpoch(expirationTimestamp * 1000);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Could not extract token expiration: $e');
      }
    }
    
    return null;
  }
  
  /// Check if token needs refresh (expiring soon)
  /// 
  /// Returns true if token expires within the next 5 minutes.
  /// 
  /// NOTE: This method calls getToken() which may cause recursion.
  /// Use shouldRefreshTokenSync() instead if you already have the token.
  @Deprecated('Use shouldRefreshTokenSync() to avoid recursion')
  static Future<bool> shouldRefreshToken() async {
    // Disabled to prevent recursion with getToken()
    // Use shouldRefreshTokenSync() with token parameter instead
    return false;
  }
  
  /// Check if token needs refresh (expiring soon) - synchronous version
  /// 
  /// Returns true if token expires within the next 5 minutes.
  /// Use this version when you already have the token to avoid recursion.
  static bool shouldRefreshTokenSync(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }
    
    final expiration = getTokenExpiration(token);
    if (expiration == null) {
      return false; // Not a JWT, can't determine expiration
    }
    
    // Refresh if expires within 5 minutes
    final refreshThreshold = DateTime.now().add(const Duration(minutes: 5));
    final needsRefresh = expiration.isBefore(refreshThreshold);
    
    if (kDebugMode && needsRefresh) {
      debugPrint('⚠️ Token expiring soon, should refresh');
      debugPrint('   Expiration: $expiration');
      debugPrint('   Refresh threshold: $refreshThreshold');
    }
    
    return needsRefresh;
  }
  
  /// Force token refresh (logout and require re-login)
  /// 
  /// This is called when token is expired and refresh is not possible.
  static Future<void> forceReAuthentication() async {
    if (kDebugMode) {
      debugPrint('🔒 Token expired, forcing re-authentication');
    }
    
    // Remove expired token
    await TokenStorage().removeToken();
    
    // Note: Navigation to login screen should be handled by the calling code
    // This service only handles token management
  }
}

