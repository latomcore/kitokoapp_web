import 'dart:convert';

class TokenStorageResponse {
  final String status;
  final String token;

  TokenStorageResponse({
    required this.status,
    required this.token,
  });

  // Factory constructor to parse the JSON response
  factory TokenStorageResponse.fromJson(String str) {
    final jsonData = json.decode(str);
    return TokenStorageResponse(
      status: jsonData["Status"],
      token: jsonData["Token"],
    );
  }

  // Method to convert the model into a JSON string
  String toJson() {
    final jsonData = {
      "Status": status,
      "Token": token,
    };
    return json.encode(jsonData);
  }
}
