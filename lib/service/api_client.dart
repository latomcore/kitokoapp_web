import 'dart:convert';
import 'dart:math';
// import 'package:kitoko_app/core/app_export.dart';
import 'package:http/http.dart' as http;
import 'package:kitokopay/service/token_storage.dart';
import 'package:get/get.dart';

class ApiClient extends GetConnect {
  static const String elmsBaseUrl = 'https://kitokoapp.com/elms';

  static String username = 'L@T0wU8eR';
  static String password = 'TGF0MHdDb1IzU3Yz';
  static String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  static const String loadApiEndPoint = '$elmsBaseUrl/load';
  static const String authApiEndPoint = '$elmsBaseUrl/auth';
  static const String coreApiEndPoint = '$elmsBaseUrl/core';

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

      http.Response response = await http.post(
        Uri.parse(authApiEndPoint),
        headers: headers,
        body: json.encode(authRequest),
      );

      if (response.statusCode == 200) {
        TokenStorage().setToken(response.body);
      }
    } catch (e) {}
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
