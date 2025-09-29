import 'dart:convert';

class ApplyLoanResponse {
  final String status;
  final String type;
  final String token;
  final LoanData data;

  ApplyLoanResponse({
    required this.status,
    required this.type,
    required this.token,
    required this.data,
  });

  // Factory constructor to parse the JSON response
  factory ApplyLoanResponse.fromJson(String str) {
    final jsonData = json.decode(str);
    return ApplyLoanResponse(
      status: jsonData["Status"],
      type: jsonData["Type"],
      token: jsonData["Token"],
      data: LoanData.fromJson(jsonData["Data"]),
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
}

class LoanData {
  final String loanAmount;
  final String loanId;
  final String loanStatus;
  final String paymentMethod;
  final String dueDate;

  LoanData({
    required this.loanAmount,
    required this.loanId,
    required this.loanStatus,
    required this.paymentMethod,
    required this.dueDate,
  });

  // Factory constructor to parse the "Data" field
  factory LoanData.fromJson(String str) {
    final jsonData = json.decode(str);
    return LoanData(
      loanAmount: jsonData["LoanAmount"],
      loanId: jsonData["LoanId"],
      loanStatus: jsonData["LoanStatus"],
      paymentMethod: jsonData["PaymentMethod"],
      dueDate: jsonData["DueDate"],
    );
  }

  // Method to convert the model into a JSON string
  String toJson() {
    final jsonData = {
      "LoanAmount": loanAmount,
      "LoanId": loanId,
      "LoanStatus": loanStatus,
      "PaymentMethod": paymentMethod,
      "DueDate": dueDate,
    };
    return json.encode(jsonData);
  }
}
