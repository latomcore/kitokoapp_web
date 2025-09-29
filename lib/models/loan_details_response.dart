import 'dart:convert';

class LoanDetailsResponse {
  final String status;
  final String type;
  final String token;
  final LoanDetailsData data;

  LoanDetailsResponse({
    required this.status,
    required this.type,
    required this.token,
    required this.data,
  });

  // Factory constructor to parse the JSON response
  factory LoanDetailsResponse.fromJson(String str) {
    final jsonData = json.decode(str);
    return LoanDetailsResponse(
      status: jsonData["Status"],
      type: jsonData["Type"],
      token: jsonData["Token"],
      data: LoanDetailsData.fromJson(jsonData["Data"]),
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

class LoanDetailsData {
  final List<Schedule> schedules;
  final List<Transaction> transactions;
  final LoanDetails loanDetails;

  LoanDetailsData({
    required this.schedules,
    required this.transactions,
    required this.loanDetails,
  });

  // Factory constructor to parse the "Data" field
  factory LoanDetailsData.fromJson(Map<String, dynamic> jsonData) {
    return LoanDetailsData(
      schedules: List<Schedule>.from(
          json.decode(jsonData["Schedules"]).map((x) => Schedule.fromJson(x))),
      transactions: List<Transaction>.from(json
          .decode(jsonData["Transactions"])
          .map((x) => Transaction.fromJson(x))),
      loanDetails: LoanDetails.fromJson(jsonData["Details"]),
    );
  }

  // Method to convert the model into a JSON string
  String toJson() {
    final jsonData = {
      "Schedules": json.encode(schedules.map((x) => x.toJson()).toList()),
      "Transactions": json.encode(transactions.map((x) => x.toJson()).toList()),
      "Details": loanDetails.toJson(),
    };
    return json.encode(jsonData);
  }
}

class Schedule {
  final int id;
  final int daysInPeriod;
  final double totalCredits;
  final String fromDate;
  final String dueDate;
  final double principalDue;
  final double amountDueForPeriod;
  final double balance;

  Schedule({
    required this.id,
    required this.daysInPeriod,
    required this.totalCredits,
    required this.fromDate,
    required this.dueDate,
    required this.principalDue,
    required this.amountDueForPeriod,
    required this.balance,
  });

  // Factory constructor to parse a Schedule
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json["id"],
      daysInPeriod: json["daysinperiod"],
      totalCredits: json["totalcredits"].toDouble(),
      fromDate: json["fromdate"],
      dueDate: json["duedate"],
      principalDue: json["principaldue"].toDouble(),
      amountDueForPeriod: json["amountdueforperiod"].toDouble(),
      balance: json["balance"].toDouble(),
    );
  }

  // Method to convert the Schedule into a JSON string
  String toJson() {
    return json.encode({
      "id": id,
      "daysinperiod": daysInPeriod,
      "totalcredits": totalCredits,
      "fromdate": fromDate,
      "duedate": dueDate,
      "principaldue": principalDue,
      "amountdueforperiod": amountDueForPeriod,
      "balance": balance,
    });
  }
}

class Transaction {
  final int id;
  final String type;
  final String date;
  final double amount;
  final double disbursalAmount;
  final double balance;
  final String receiptNumber;

  Transaction({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.disbursalAmount,
    required this.balance,
    required this.receiptNumber,
  });

  // Factory constructor to parse a Transaction
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json["id"],
      type: json["type"],
      date: json["date"],
      amount: json["amount"].toDouble(),
      disbursalAmount: json["disbursalamount"].toDouble(),
      balance: json["balance"].toDouble(),
      receiptNumber: json["receiptnumber"],
    );
  }

  // Method to convert the Transaction into a JSON string
  String toJson() {
    return json.encode({
      "id": id,
      "type": type,
      "date": date,
      "amount": amount,
      "disbursalamount": disbursalAmount,
      "balance": balance,
      "receiptnumber": receiptNumber,
    });
  }
}

class LoanDetails {
  final double totalRepaymentExpected;
  final double totalPrincipalDisbursed;
  final String currency;
  final String pastDueDays;
  final double totalPrincipalExpected;
  final int loanTermInDays;
  final String id;
  final String paymentBeforeDate;
  final double interestRate;
  final double principal;
  final double totalOutstanding;

  LoanDetails({
    required this.totalRepaymentExpected,
    required this.totalPrincipalDisbursed,
    required this.currency,
    required this.pastDueDays,
    required this.totalPrincipalExpected,
    required this.loanTermInDays,
    required this.id,
    required this.paymentBeforeDate,
    required this.interestRate,
    required this.principal,
    required this.totalOutstanding,
  });

  // Factory constructor to parse LoanDetails
  factory LoanDetails.fromJson(Map<String, dynamic> json) {
    return LoanDetails(
      totalRepaymentExpected: json["TotalRepaymentExpected"].toDouble(),
      totalPrincipalDisbursed: json["TotalPrincipalDisbursed"].toDouble(),
      currency: json["Currency"],
      pastDueDays: json["PastDueDays"],
      totalPrincipalExpected: json["TotalPrincipalExpected"].toDouble(),
      loanTermInDays: json["LoanTermInDays"],
      id: json["id"],
      paymentBeforeDate: json["PaymentBeforeDate"],
      interestRate: json["InterestRate"].toDouble(),
      principal: json["Principal"].toDouble(),
      totalOutstanding: json["TotalOutstanding"].toDouble(),
    );
  }

  // Method to convert LoanDetails into a JSON string
  String toJson() {
    return json.encode({
      "TotalRepaymentExpected": totalRepaymentExpected,
      "TotalPrincipalDisbursed": totalPrincipalDisbursed,
      "Currency": currency,
      "PastDueDays": pastDueDays,
      "TotalPrincipalExpected": totalPrincipalExpected,
      "LoanTermInDays": loanTermInDays,
      "id": id,
      "PaymentBeforeDate": paymentBeforeDate,
      "InterestRate": interestRate,
      "Principal": principal,
      "TotalOutstanding": totalOutstanding,
    });
  }
}
