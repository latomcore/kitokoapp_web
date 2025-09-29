import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kitokopay/service/api_client_helper_utils.dart';
import "package:kitokopay/src/screens/ui/repay.dart";
import 'package:kitokopay/src/screens/utils/session_manager.dart';
import "package:kitokopay/src/screens/ui/loans.dart";

class MyLoansPage extends StatefulWidget {
  const MyLoansPage({super.key});

  @override
  State<MyLoansPage> createState() => _MyLoansPageState();
}

class _MyLoansPageState extends State<MyLoansPage> {
  int _selectedTabIndex = 0;
  int _selectedCardIndex = -1;
  bool _isDetailView = false; // Start in list view, not detail view
  List<dynamic> _loans = [];
  Map<String, dynamic>? _selectedLoanDetails;
  bool _isLoading = true;
  bool _isFetchingDetails = false;

  @override
  void initState() {
    super.initState();
    _fetchLoans();
    GlobalSessionManager().startMonitoring(context);
  }

  Future<void> _fetchLoans() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? loginDetails = prefs.getString('loginDetails');

      if (loginDetails == null) {
        _loans = [];
        throw Exception("Login details not found.");
      }

      ElmsSSL elmsSSL = ElmsSSL();
      final cleanedLogin = elmsSSL.cleanResponse(loginDetails);
      final loans = cleanedLogin['Data']['Loans'];

      if (loans == null || loans.isEmpty) {
        _loans = [];
      }

      final decodedLoans = jsonDecode(loans);

      setState(() {
        _loans = decodedLoans;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _loans = [];
    }
  }

  Future<void> _fetchLoanDetailsById(String loanId) async {
    setState(() {
      _isFetchingDetails = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ElmsSSL elmsSSL = ElmsSSL();

      final response = await elmsSSL.fetchLoanDetailsById(loanId);
      final result = jsonDecode(response);

      if (result['status'] == 'success') {
        final fetchedDetails = prefs.getString('fetchedLoanDetails');

        if (fetchedDetails != null && fetchedDetails.isNotEmpty) {
          final parsedDetails = jsonDecode(fetchedDetails);
          final cleanedResponse =
              elmsSSL.cleanResponse(jsonEncode(parsedDetails));

          if (cleanedResponse['Data']?['Details'] != null) {
            setState(() {
              _selectedLoanDetails =
                  cleanedResponse['Data']['Details'] as Map<String, dynamic>;
              _isDetailView = true; // Switch to details view on mobile
            });
          } else {
            _showErrorDialog("Loan details are missing in the response.");
          }
        } else {
          _showErrorDialog("No loan details found in preferences.");
        }
      } else {
        _showErrorDialog("Failed to fetch loan details.");
      }
    } catch (error) {
      _showErrorDialog("Error fetching loan details: $error");
    } finally {
      setState(() {
        _isFetchingDetails = false;
      });
    }
  }

  void _selectLoan(int index) {
    setState(() {
      _selectedCardIndex = index;
    });
    final loanId = _loans[index]['LoanId'];
    _fetchLoanDetailsById(loanId);
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    if (index == 1) {
      // Navigate to Repayments screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RepayLoanScreen()),
      );
    } else if (index == 2) {
      // Navigate to New Loan screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoansPage()),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => GlobalSessionManager().updateActivity(context),
      child: Scaffold(
        backgroundColor: const Color(0xFF3C4B9D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3C4B9D),
          elevation: 0,
          title: Text(
            _isDetailView ? "Loan Details" : "My Loans",
            style: const TextStyle(color: Colors.white),
          ),
          leading: _isDetailView
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() => _isDetailView = false),
                )
              : null,
        ),
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3C4B9D),
                    Color(0xFF151A37),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 20),
                _buildCardTabBar(), // Tabs
                const SizedBox(height: 20),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        // Desktop or large screen
                        return Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildLoansList(),
                            ),
                            Container(
                              width: 1,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            Expanded(
                              flex: 2,
                              child: _isFetchingDetails
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : _buildLoanDetails(),
                            ),
                          ],
                        );
                      } else {
                        // Mobile screen
                        return _isDetailView
                            ? _buildLoanDetails()
                            : _buildLoansList();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4564A8),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCardTab('Loans', 0),
          _buildCardTab('Repayments', 1),
          _buildCardTab('New Loan', 2),
        ],
      ),
    );
  }

  Widget _buildCardTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => _navigateToTab(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF3C4B9D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF3C4B9D) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoansList() {
    if (_loans.isEmpty) {
      return const Center(
        child: Text(
          "No loans available.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _loans.length,
      itemBuilder: (context, index) {
        final loan = _loans[index];
        final isSelected = _selectedCardIndex == index;

        return Card(
          elevation: 6,
          shadowColor: Colors.black45,
          color: isSelected ? Colors.blueAccent : const Color(0xFF3C4B9D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: ${loan['Names'] ?? 'N/A'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Status: ${loan['LoanStatus'] ?? 'N/A'}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Reference ID: ${loan['ReferenceId'] ?? 'N/A'}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Repayment Date: ${loan['RepaymentDate'] ?? 'N/A'}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => _selectLoan(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoanDetails() {
    if (_selectedLoanDetails == null) {
      return const Center(
        child: Text(
          "Select a loan to view details.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Loan Details",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailsRow(
              "Total Repayment",
              _selectedLoanDetails!['TotalRepaymentExpected']?.toString() ??
                  "N/A"),
          _buildDetailsRow(
              "Principal Disbursed",
              _selectedLoanDetails!['TotalPrincipalDisbursed']?.toString() ??
                  "N/A"),
          _buildDetailsRow(
              "Currency", _selectedLoanDetails!['Currency'] ?? "N/A"),
          _buildDetailsRow("Interest Rate",
              _selectedLoanDetails!['InterestRate']?.toString() ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
