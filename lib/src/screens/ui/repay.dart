import 'package:flutter/material.dart';
import 'package:kitokopay/src/customs/appbar.dart';
import "package:kitokopay/src/screens/ui/loans.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:kitokopay/service/api_client_helper_utils.dart';
import 'package:kitokopay/src/screens/utils/session_manager.dart';
import 'package:flutter/services.dart';

class RepayLoanScreen extends StatefulWidget {
  const RepayLoanScreen({super.key});

  @override
  _RepayLoanScreenState createState() => _RepayLoanScreenState();
}

class _RepayLoanScreenState extends State<RepayLoanScreen> {
  String paymentType = "FULLPAY"; // Default payment type
  String? partialAmount; // For Partial Payment
  bool isLoading = false; // Loading state for repayment form
  bool isPinSubmitting = false; // Loading state for PIN submission
  int _currentTab = 0; // 0: Repayment Info, 1: Enter PIN, 2: Confirmation
  String pinInput = ""; // Store the entered PIN
  String message = ""; // Message for success or error

  // Variables to store loan details and login details
  String interestRate = "N/A";
  String outstandingAmount = "N/A";
  String mobileNumber = "N/A";
  String loanStatus = ""; // Track loan status

  @override
  void initState() {
    super.initState();
    _loadDetailsFromPrefs();
    GlobalSessionManager().startMonitoring(context);
  }

  Future<void> _loadDetailsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    ElmsSSL elmsSSL = ElmsSSL();

    // Fetch and parse loginDetails
    String? loginDetailsStr = prefs.getString('loginDetails');
    if (loginDetailsStr != null) {
      final cleanedLogin = elmsSSL.cleanResponse(loginDetailsStr);

      setState(() {
        interestRate = cleanedLogin['Data']['InterestRate']?.toString() ??
            "N/A"; // Extract InterestRate
        mobileNumber = cleanedLogin['Data']['MobileNumber'] ??
            "N/A"; // Extract MobileNumber
        loanStatus =
            cleanedLogin['Data']['LoanStatus'] ?? ""; // Extract LoanStatus
      });
    }

    // Fetch and parse loanDetails
    String? loanDetailsStr = prefs.getString('loanDetails');
    if (loanDetailsStr != null) {
      final loanDetails = elmsSSL.cleanResponse(loanDetailsStr);

      setState(() {
        outstandingAmount =
            loanDetails['Data']['Details']['TotalOutstanding']?.toString() ??
                "0.0"; // Extract Outstanding Amount
      });
    }
  }

  Future<void> _submitRepayment() async {
    setState(() => isPinSubmitting = true);

    try {
      // Determine payment type and amount
      String type = paymentType;
      String amount = paymentType == "PARTIALPAY"
          ? partialAmount ?? "0"
          : outstandingAmount;
      String pin = pinInput;

      // Call repayLoan function from ElmsSSL
      ElmsSSL elmsSSL = ElmsSSL();
      String response = await elmsSSL.repayLoan(type, amount, pin);

      // Parse the response
      Map<String, dynamic> result = jsonDecode(response);

      if (result['status'] == 'success') {
        setState(() {
          message = result['message']; // Success message from the server
          _currentTab = 2; // Navigate to confirmation screen
        });
      } else {
        setState(() {
          message = result['message'] ?? "Repayment failed!";
          _currentTab = 2; // Navigate to confirmation screen with error
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    } finally {
      setState(() => isPinSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => GlobalSessionManager().updateActivity(context),
      child: Scaffold(
        appBar: const CustomAppBar(),
        backgroundColor: const Color(0xFF3C4B9D), // Consistent background color
        body: loanStatus == "PendingPayment"
            ? _currentTab == 0
                ? _buildRepaymentForm()
                : _currentTab == 1
                    ? _buildPinEntry()
                    : _buildConfirmation()
            : _buildNoLoansMessage(),
      ),
    );
  }

  // Show message when no loans are available to repay
  Widget _buildNoLoansMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "No loans to repay.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoansPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7FC1E4), // Button color
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Apply Loan",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Repayment form screen
  Widget _buildRepaymentForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Loan Information Section
            _buildNonEditableField("Mobile Number", mobileNumber),
            const SizedBox(height: 10),
            _buildNonEditableField("Interest Rate", interestRate),
            const SizedBox(height: 10),
            _buildNonEditableField(
                "Total Outstanding Amount", outstandingAmount),
            const SizedBox(height: 20),
            // Dropdown for Payment Type
            const Text(
              "Select Payment Method",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white), // White text
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: paymentType,
                isExpanded: true,
                underline: Container(), // Remove default underline
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                items: [
                  DropdownMenuItem(
                    value: "FULLPAY",
                    child: Text(
                      "Full payment",
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "PARTIALPAY",
                    child: Text(
                      "Partial payment",
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    paymentType = value!;
                    partialAmount = null; // Reset partial amount
                  });
                },
              ),
            ),
            // Conditional Input for Partial Payment
// Conditional Input for Partial Payment
            if (paymentType == "PARTIALPAY") ...[
              const SizedBox(height: 20),
              const Text(
                "Enter amount",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white), // White text
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly, // Restrict input to digits only
                ],
                decoration: InputDecoration(
                  hintText: "Enter amount",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    double inputAmount = double.tryParse(value) ?? 0.0;
                    double maxOutstandingAmount =
                        double.tryParse(outstandingAmount) ?? 0.0;

                    if (inputAmount > maxOutstandingAmount) {
                      partialAmount = maxOutstandingAmount.toString();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Amount cannot exceed outstanding balance."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      partialAmount = value; // Update the partial amount
                    }
                  });
                },
              ),
            ],

            const SizedBox(height: 30),
            // Make Repayment Button
            Center(
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (paymentType == "PARTIALPAY" &&
                            (partialAmount == null || partialAmount!.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter an amount."),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _currentTab = 1; // Navigate to PIN entry
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7FC1E4), // Button blue color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Make repayment",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PIN entry screen
  Widget _buildPinEntry() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Authorize",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white), // White text
        ),
        const SizedBox(height: 10),
        const Text(
          "Enter your PIN",
          style: TextStyle(fontSize: 16, color: Colors.white), // White text
        ),
        const SizedBox(height: 30),
        // PIN circles
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: index < pinInput.length
                    ? const Color(0xFF7FC1E4)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7FC1E4)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        // PIN Dialpad
        _buildDialPad(),
        const SizedBox(height: 30),
        // Submit Button
        ElevatedButton(
          onPressed: isPinSubmitting ? null : _submitRepayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7FC1E4),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isPinSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  "Submit",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
        ),
      ],
    );
  }

  // Confirmation screen
  Widget _buildConfirmation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7FC1E4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Done",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PIN Dialpad
  Widget _buildDialPad() {
    List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    return Column(
      children: [
        for (int i = 0; i < 3; i++) // Rows for numbers 1-9
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (j) => _buildDialButton(numbers[i * 3 + j]),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 60),
            _buildDialButton(0),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  // Individual Dial Button
  Widget _buildDialButton(int number) {
    return GestureDetector(
      onTap: () {
        if (pinInput.length < 4) {
          setState(() => pinInput += number.toString());
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF7FC1E4), width: 1.5),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7FC1E4),
            ),
          ),
        ),
      ),
    );
  }

  // Backspace Button
  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: () {
        if (pinInput.isNotEmpty) {
          setState(() {
            pinInput = pinInput.substring(0, pinInput.length - 1);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF7FC1E4), width: 1.5),
        ),
        child: const Center(
          child: Icon(
            Icons.backspace,
            color: Color(0xFF7FC1E4),
            size: 24,
          ),
        ),
      ),
    );
  }

  // Non-editable field builder
  Widget _buildNonEditableField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
