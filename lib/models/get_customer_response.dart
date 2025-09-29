import 'dart:convert';
import 'dart:html'; // For localStorage

class GetCustomerResponse {
  final String status;
  final String type;
  final String token;
  final CustomerData data;

  GetCustomerResponse({
    required this.status,
    required this.type,
    required this.token,
    required this.data,
  });

  // Factory constructor to parse the JSON response
  factory GetCustomerResponse.fromJson(String str) {
    final jsonData = json.decode(str);
    return GetCustomerResponse(
      status: jsonData["Status"],
      type: jsonData["Type"],
      token: jsonData["Token"],
      data: CustomerData.fromJson(jsonData["Data"]),
    );
  }

  // Method to convert the model into a JSON string
  String toJson() {
    final jsonData = {
      "Status": status,
      "Type": type,
      "Token": token,
      "Data": data.toJson(),
    };
    return json.encode(jsonData);
  }

  // Save appId and customerId in localStorage for 5 minutes
  void saveToLocalStorage() {
    final expirationTime =
        DateTime.now().add(const Duration(minutes: 5)).toIso8601String();
    window.localStorage['appId'] = data.appId;
    window.localStorage['customerId'] = data.customerId;
    window.localStorage['expiresAt'] = expirationTime;
  }

  // Check if data is still valid (within 5 minutes)
  bool isDataValid() {
    final expirationTimeString = window.localStorage['expiresAt'];
    if (expirationTimeString != null) {
      final expirationTime = DateTime.parse(expirationTimeString);
      return DateTime.now().isBefore(expirationTime);
    }
    return false;
  }

  // Clear localStorage data
  void clearLocalStorage() {
    window.localStorage.remove('appId');
    window.localStorage.remove('customerId');
    window.localStorage.remove('expiresAt');
  }
}

class CustomerData {
  final String status;
  final String appId;
  final String customerId;

  CustomerData({
    required this.status,
    required this.appId,
    required this.customerId,
  });

  // Factory constructor to parse the nested "Data" object
  factory CustomerData.fromJson(String str) {
    final jsonData = json.decode(str);
    return CustomerData(
      status: jsonData["Status"],
      appId: jsonData["AppId"],
      customerId: jsonData["CustomerId"],
    );
  }

  // Method to convert the model into a JSON string
  String toJson() {
    final jsonData = {
      "Status": status,
      "AppId": appId,
      "CustomerId": customerId,
    };
    return json.encode(jsonData);
  }
}
