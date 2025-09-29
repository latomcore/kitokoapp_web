import 'dart:convert';

class ActivateUserResponse {
  final String status;
  final String type;
  final ActivateUserData data;

  ActivateUserResponse({
    required this.status,
    required this.type,
    required this.data,
  });

  // Factory constructor to parse the JSON response
  factory ActivateUserResponse.fromJson(String str) {
    final jsonData = json.decode(str);
    return ActivateUserResponse(
      status: jsonData["Status"],
      type: jsonData["Type"],
      data: ActivateUserData.fromJson(jsonData["Data"]),
    );
  }

  // Method to convert the model into a JSON string
  String toJson() {
    final jsonData = {
      "Status": status,
      "Type": type,
      "Data": data.toJson(),
    };
    return json.encode(jsonData);
  }
}

class ActivateUserData {
  final String deviceId;
  final String customerId;
  final String display;

  ActivateUserData({
    required this.deviceId,
    required this.customerId,
    required this.display,
  });

  // Factory constructor to parse the nested "Data" object
  factory ActivateUserData.fromJson(String str) {
    final jsonData = json.decode(str);
    return ActivateUserData(
      deviceId: jsonData["DeviceId"],
      customerId: jsonData["CustomerId"],
      display: jsonData["Display"],
    );
  }

  // Method to convert the model into a JSON string
  String toJson() {
    final jsonData = {
      "DeviceId": deviceId,
      "CustomerId": customerId,
      "Display": display,
    };
    return json.encode(jsonData);
  }
}
