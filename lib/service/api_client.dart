import 'dart:convert';
import 'dart:math';
// import 'package:kitoko_app/core/app_export.dart';
import 'package:http/http.dart' as http;
import 'package:kitokopay/service/token_storage.dart';
import 'package:get/get.dart';
import 'package:kitokopay/config/app_config.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

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
    try {
      var headers = {
        'Content-Type': 'application/json',
      };

      String requestBody = json.encode(authRequest);
      
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
    } catch (e, stackTrace) {
      // Log errors only in debug mode, sanitized
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('❌ AUTH REQUEST ERROR');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('Error Type: ${e.runtimeType}');
        // Don't log full error message (may contain sensitive data)
        debugPrint('Error: [Error occurred during auth request]');
        // Don't log full stack trace in production
        debugPrint('═══════════════════════════════════════════════════════════');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> coreRequest(
      String token, Map<String, dynamic> coreRequest, String command) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(coreApiEndPoint),
        headers: headers,
        body: jsonEncode(coreRequest),
      );

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
