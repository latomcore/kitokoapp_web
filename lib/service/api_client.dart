import 'dart:convert';
import 'dart:math';
// import 'package:kitoko_app/core/app_export.dart';
import 'package:http/http.dart' as http;
import 'package:kitokopay/service/token_storage.dart';
import 'package:get/get.dart';
import 'package:kitokopay/config/app_config.dart';
import 'package:kitokopay/service/token_refresh_service.dart'; // PHASE 3: Token expiration
import 'package:kitokopay/service/rate_limiter.dart'; // PHASE 3: Rate limiting
import 'package:kitokopay/service/rate_limit_exception.dart'; // PHASE 3: Rate limit exception
import 'package:kitokopay/service/request_signer.dart'; // PHASE 3: Request signing
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;

class ApiClient extends GetConnect {
  static String get elmsBaseUrl => AppConfig.elmsBaseUrl;
  
  /// Get Basic Auth header using credentials from secure storage
  static Future<String> getBasicAuth() async {
    final username = await AppConfig.getApiUsername();
    final password = await AppConfig.getApiPassword();
    final credentials = '$username:$password';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }
  
  // Deprecated: Use getBasicAuth() instead
  @Deprecated('Use getBasicAuth() async method instead')
  static String get username => AppConfig.apiUsername;
  
  @Deprecated('Use getBasicAuth() async method instead')
  static String get password => AppConfig.apiPassword;
  
  @Deprecated('Use getBasicAuth() async method instead')
  static String get basicAuth {
    final username = AppConfig.apiUsername;
    final password = AppConfig.apiPassword;
    return 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
  }

  static String get loadApiEndPoint => AppConfig.loadApiEndPoint;
  static String get authApiEndPoint => AppConfig.authApiEndPoint;
  static String get coreApiEndPoint => AppConfig.coreApiEndPoint;

  /// Generate a cryptographically secure random string
  /// 
  /// Uses Random.secure() on mobile platforms for cryptographic security.
  /// Falls back to Random() on web (Random.secure() not available on web).
  /// 
  /// This is used for generating encryption keys and IVs, so security is critical.
  String generateRandomString(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    
    Random random;
    try {
      // Try to use cryptographically secure random (mobile platforms)
      random = Random.secure();
      
      if (kDebugMode) {
        debugPrint('✅ Using Random.secure() for cryptographic security');
      }
    } catch (e) {
      // Fallback to regular Random() for web (Random.secure() not available)
      if (kDebugMode) {
        debugPrint('⚠️ Random.secure() not available, using Random() fallback (web platform)');
        debugPrint('   Note: Web platform limitation - Random.secure() not supported');
      }
      random = Random();
    }
    
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  Future<void> authRequest(Map<String, String> authRequest) async {
    // PHASE 3: Check rate limit before making request
    final rateLimiter = RateLimiter();
    if (!rateLimiter.checkRateLimit(authApiEndPoint)) {
      final waitTime = rateLimiter.getWaitTime(authApiEndPoint);
      throw RateLimitException(
        'Too many requests. Please wait ${waitTime}s before trying again.',
        waitTime: waitTime,
      );
    }

    try {
      var headers = {
        'Content-Type': 'application/json',
      };

      String requestBody = json.encode(authRequest);
      
      // PHASE 3: Sign request (optional - can be enabled/disabled)
      // Request signing adds extra security by preventing tampering
      // NOTE: Disabled on web to avoid CORS preflight issues
      // NOTE: If server doesn't support request signing, these headers are ignored
      if (!kIsWeb) {
        // Only sign requests on mobile (web has CORS restrictions)
        try {
          final requestSigner = RequestSigner();
          final signatureHeaders = await requestSigner.signRequest(
            method: 'POST',
            url: authApiEndPoint,
            body: authRequest,
            token: null, // No token for auth requests
          );
          headers.addAll(signatureHeaders);
        } catch (e) {
          // If request signing fails, continue without it (non-critical)
          if (kDebugMode) {
            debugPrint('⚠️ Request signing failed, continuing without signature: $e');
          }
        }
      } else if (kDebugMode) {
        debugPrint('ℹ️ Request signing skipped on web (CORS compatibility)');
      }
      
      // Log the request details (only in debug mode, sanitized)
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('🔐 AUTH REQUEST DETAILS');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('📍 URL: $authApiEndPoint');
        debugPrint('📋 Headers: [Content-Type: application/json]');
        // Don't log full request body (contains sensitive encrypted data)
        debugPrint('📦 Request Body: [Encrypted - Length: ${requestBody.length} chars]');
        debugPrint('═══════════════════════════════════════════════════════════');
      }

      http.Response response = await http.post(
        Uri.parse(authApiEndPoint),
        headers: headers,
        body: requestBody,
      );

      // Log the response details (only in debug mode, sanitized)
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('📥 AUTH RESPONSE DETAILS');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('📊 Status Code: ${response.statusCode}');
        // Don't log full response body (contains tokens)
        debugPrint('📄 Response Body: [Length: ${response.body.length} chars]');
        debugPrint('═══════════════════════════════════════════════════════════');
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ Auth successful! Token saved.');
        }
        TokenStorage().setToken(response.body);
      } else {
        if (kDebugMode) {
          debugPrint('❌ Auth failed! Status code: ${response.statusCode}');
          // Don't log full error response (may contain sensitive info)
        }
      }
    } catch (e) {
      // Log errors only in debug mode, sanitized
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('❌ AUTH REQUEST ERROR');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('Error Type: ${e.runtimeType}');
        // Log error message for debugging (helps identify connection issues)
        final errorMsg = e.toString();
        // Don't log full error if it contains sensitive data, but show enough to debug
        if (errorMsg.length > 200) {
          debugPrint('Error: ${errorMsg.substring(0, 200)}...');
        } else {
          debugPrint('Error: $errorMsg');
        }
        debugPrint('═══════════════════════════════════════════════════════════');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> coreRequest(
      String token, Map<String, dynamic> coreRequest, String command) async {
    // PHASE 3: Check token expiration before making request
    if (TokenRefreshService.isTokenExpired(token)) {
      if (kDebugMode) {
        debugPrint('❌ Token expired, cannot make API request');
      }
      
      // Force re-authentication
      await TokenRefreshService.forceReAuthentication();
      
      return {
        "statusCode": 401, // Unauthorized
        "body": jsonEncode({
          "status": "error",
          "message": "Token expired. Please login again.",
        }),
      };
    }
    
    // PHASE 3: Check rate limit before making request
    final rateLimiter = RateLimiter();
    if (!rateLimiter.checkRateLimit(coreApiEndPoint)) {
      final waitTime = rateLimiter.getWaitTime(coreApiEndPoint);
      return {
        "statusCode": 429, // Too Many Requests
        "body": jsonEncode({
          "status": "error",
          "message": "Too many requests. Please wait ${waitTime}s before trying again.",
        }),
      };
    }
    
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    
    // PHASE 3: Sign request (optional - can be enabled/disabled)
    // Request signing adds extra security by preventing tampering
    // NOTE: Disabled on web to avoid CORS preflight issues
    // NOTE: If server doesn't support request signing, these headers are ignored
    if (!kIsWeb) {
      // Only sign requests on mobile (web has CORS restrictions)
      try {
        final requestSigner = RequestSigner();
        final signatureHeaders = await requestSigner.signRequest(
          method: 'POST',
          url: coreApiEndPoint,
          body: coreRequest,
          token: token,
        );
        headers.addAll(signatureHeaders);
      } catch (e) {
        // If request signing fails, continue without it (non-critical)
        if (kDebugMode) {
          debugPrint('⚠️ Request signing failed, continuing without signature: $e');
        }
      }
    } else if (kDebugMode) {
      debugPrint('ℹ️ Request signing skipped on web (CORS compatibility)');
    }

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(coreApiEndPoint),
        headers: headers,
        body: jsonEncode(coreRequest),
      );

      // PHASE 3: Check if response indicates token expiration
      if (response.statusCode == 401) {
        if (kDebugMode) {
          debugPrint('⚠️ Server returned 401, token may be expired');
        }
        // Token might be expired on server side, remove it
        await TokenRefreshService.forceReAuthentication();
      }

      // Return the status code and response body
      return {
        "statusCode": response.statusCode,
        "body": response.body,
      };
    } catch (e) {
      // Return an error structure in case of exceptions
      return {
        "statusCode": 500, // Custom status code for exceptions
        "body": jsonEncode({
          "status": "error",
          "message": "Exception occurred: ${e.toString()}",
        }),
      };
    }
  }
}
