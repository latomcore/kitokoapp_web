import 'dart:convert';

class LoginResponse {
  final String status;
  final String type;
  final LoanData data;

  LoginResponse({
    required this.status,
    required this.type,
    required this.data,
  });

  // Factory constructor to parse the JSON response
  factory LoginResponse.fromJson(Map<String, dynamic> jsonData) {
    return LoginResponse(
      status: jsonData["Status"],
      type: jsonData["Type"],
      data: LoanData.fromJson(jsonData["Data"]),
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

class LoanData {
  final List<Loan> loans;
  final String loanBalance;
  final Map<String, String> rates;
  final String email;
  final String loanStatus;
  final String identification;
  final String processingFee;
  final String loanAmount;
  final String referenceId;
  final String currency;
  final String loanTermPeriod;
  final String dueDate;
  final String interestRate;
  final String dateOfBirth;
  final String limitMessage;
  final String limitStatus;
  final String firstName;
  final String limitAmount;
  final List<Customer> customers;
  final String displayLimit;
  final String applicationFee;
  final String country;
  final String? paymentMethod;
  final String lastName;

  LoanData({
    required this.loans,
    required this.loanBalance,
    required this.rates,
    required this.email,
    required this.loanStatus,
    required this.identification,
    required this.processingFee,
    required this.loanAmount,
    required this.referenceId,
    required this.currency,
    required this.loanTermPeriod,
    required this.dueDate,
    required this.interestRate,
    required this.dateOfBirth,
    required this.limitMessage,
    required this.limitStatus,
    required this.firstName,
    required this.limitAmount,
    required this.customers,
    required this.displayLimit,
    required this.applicationFee,
    required this.country,
    this.paymentMethod,
    required this.lastName,
  });

  // Factory constructor to parse the "Data" field
  factory LoanData.fromJson(Map<String, dynamic> jsonData) {
    return LoanData(
      loans: (jsonData["Loans"] is String)
          ? List<Loan>.from(
              json.decode(jsonData["Loans"]).map((x) => Loan.fromJson(x)))
          : [], // handle empty list if not string
      loanBalance: jsonData["LoanBalance"],
      rates: (jsonData["Rates"] is String)
          ? Map<String, String>.from(json.decode(jsonData["Rates"]))
          : {}, // handle empty map if not string
      email: jsonData["Email"],
      loanStatus: jsonData["LoanStatus"],
      identification: jsonData["Identification"],
      processingFee: jsonData["ProcessingFee"],
      loanAmount: jsonData["LoanAmount"],
      referenceId: jsonData["ReferenceId"],
      currency: jsonData["Currency"],
      loanTermPeriod: jsonData["LoanTermPeriod"],
      dueDate: jsonData["DueDate"],
      interestRate: jsonData["InterestRate"],
      dateOfBirth: jsonData["DateOfBirth"],
      limitMessage: jsonData["LimitMessage"],
      limitStatus: jsonData["LimitStatus"],
      firstName: jsonData["FirstName"],
      limitAmount: jsonData["LimitAmount"],
      customers: (jsonData["Customers"] is String)
          ? List<Customer>.from(json
              .decode(jsonData["Customers"])
              .map((x) => Customer.fromJson(x)))
          : [],
      displayLimit: jsonData["DisplayLimit"],
      applicationFee: jsonData["ApplicationFee"],
      country: jsonData["Country"],
      paymentMethod: jsonData["PaymentMethod"],
      lastName: jsonData["LastName"],
    );
  }

  // Method to convert the model into a JSON string
  String toJson() {
    final jsonData = {
      "Loans": json.encode(loans.map((x) => x.toJson()).toList()),
      "LoanBalance": loanBalance,
      "Rates": json.encode(rates),
      "Email": email,
      "LoanStatus": loanStatus,
      "Identification": identification,
      "ProcessingFee": processingFee,
      "LoanAmount": loanAmount,
      "ReferenceId": referenceId,
      "Currency": currency,
      "LoanTermPeriod": loanTermPeriod,
      "DueDate": dueDate,
      "InterestRate": interestRate,
      "DateOfBirth": dateOfBirth,
      "LimitMessage": limitMessage,
      "LimitStatus": limitStatus,
      "FirstName": firstName,
      "LimitAmount": limitAmount,
      "Customers": json.encode(customers.map((x) => x.toJson()).toList()),
      "DisplayLimit": displayLimit,
      "ApplicationFee": applicationFee,
      "Country": country,
      "PaymentMethod": paymentMethod,
      "LastName": lastName,
    };
    return json.encode(jsonData);
  }
}

// Models for Loan and Customer
class Loan {
  final String loanId;
  final String loanStatus;
  final String principalAmount;
  final String currentBalance;
  final String date;
  final String referenceId;
  final String repaymentDate;
  final String requestType;
  final String mobileNumber;
  final String names;
  final String id;

  Loan({
    required this.loanId,
    required this.loanStatus,
    required this.principalAmount,
    required this.currentBalance,
    required this.date,
    required this.referenceId,
    required this.repaymentDate,
    required this.requestType,
    required this.mobileNumber,
    required this.names,
    required this.id,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      loanId: json["LoanId"],
      loanStatus: json["LoanStatus"],
      principalAmount: json["PrincipalAmount"],
      currentBalance: json["CurrentBalance"],
      date: json["Date"],
      referenceId: json["ReferenceId"],
      repaymentDate: json["RepaymentDate"],
      requestType: json["RequestType"],
      mobileNumber: json["MobileNumber"],
      names: json["Names"],
      id: json["Id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "LoanId": loanId,
        "LoanStatus": loanStatus,
        "PrincipalAmount": principalAmount,
        "CurrentBalance": currentBalance,
        "Date": date,
        "ReferenceId": referenceId,
        "RepaymentDate": repaymentDate,
        "RequestType": requestType,
        "MobileNumber": mobileNumber,
        "Names": names,
        "Id": id,
      };
}

class Customer {
  final String customerId;
  final String firstName;
  final String lastName;
  final String identification;
  final String email;
  final String mobileNumber;

  Customer({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.identification,
    required this.email,
    required this.mobileNumber,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json["CustomerId"],
      firstName: json["FirstName"],
      lastName: json["LastName"],
      identification: json["Identification"],
      email: json["Email"],
      mobileNumber: json["MobileNumber"],
    );
  }

  Map<String, dynamic> toJson() => {
        "CustomerId": customerId,
        "FirstName": firstName,
        "LastName": lastName,
        "Identification": identification,
        "Email": email,
        "MobileNumber": mobileNumber,
      };
}
