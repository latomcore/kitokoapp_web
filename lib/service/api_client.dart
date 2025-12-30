import 'dart:convert';
import 'dart:math';
// import 'package:kitoko_app/core/app_export.dart';
import 'package:http/http.dart' as http;
import 'package:kitokopay/service/token_storage.dart';
import 'package:get/get.dart';
import 'package:kitokopay/config/app_config.dart';
import 'package:flutter/foundation.dart';

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

  String generateRandomString(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  Future<void> authRequest(Map<String, String> authRequest) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
      };

      String requestBody = json.encode(authRequest);
      
      // Log the request details
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔐 AUTH REQUEST DETAILS');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📍 URL: $authApiEndPoint');
      debugPrint('📋 Headers: ${json.encode(headers)}');
      debugPrint('📦 Request Body:');
      debugPrint(requestBody);
      debugPrint('═══════════════════════════════════════════════════════════');
      
      // Log curl command for testing
      String curlCommand = 'curl -X POST "$authApiEndPoint" \\\n'
          '  -H "Content-Type: application/json" \\\n'
          '  -d \'$requestBody\'';
      debugPrint('🧪 CURL COMMAND TO TEST:');
      debugPrint(curlCommand);
      debugPrint('═══════════════════════════════════════════════════════════');

      http.Response response = await http.post(
        Uri.parse(authApiEndPoint),
        headers: headers,
        body: requestBody,
      );

      // Log the response details
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📥 AUTH RESPONSE DETAILS');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      debugPrint('📏 Response Body Length: ${response.body.length}');
      debugPrint('═══════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        debugPrint('✅ Auth successful! Token saved.');
        TokenStorage().setToken(response.body);
      } else {
        debugPrint('❌ Auth failed! Status code: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('❌ AUTH REQUEST ERROR');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Error: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Stack Trace: $stackTrace');
      debugPrint('═══════════════════════════════════════════════════════════');
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
