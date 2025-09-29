import 'dart:convert';

class ResetPinResponse {
  final String status;
  final String type;
  final String token;
  final String data;

  ResetPinResponse({
    required this.status,
    required this.type,
    required this.token,
    required this.data,
  });

  // Factory constructor to parse the JSON response
  factory ResetPinResponse.fromJson(String str) {
    final jsonData = json.decode(str);
    return ResetPinResponse(
      status: jsonData["Status"],
      type: jsonData["Type"],
      token: jsonData["Token"],
      data: jsonData["Data"],
    );
  }

  // Method to convert the model into a JSON string
  String toJson() {
    final jsonData = {
      "Status": status,
      "Type": type,
      "Token": token,
      "Data": data,
    };
    return json.encode(jsonData);
  }
}
