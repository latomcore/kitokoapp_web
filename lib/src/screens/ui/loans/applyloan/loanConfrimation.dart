import 'package:flutter/material.dart';
import 'package:kitokopay/src/customs/appbar.dart';
import 'package:kitokopay/src/customs/footer.dart';
import 'package:kitokopay/src/screens/ui/loans.dart';
import 'package:kitokopay/src/screens/ui/loans/applyloan/loanpin.dart';
import 'package:kitokopay/src/screens/ui/loans/myloans/myloans.dart';

class LoanConfirmationPage extends StatefulWidget {
  const LoanConfirmationPage({super.key});

  @override
  _LoanConfirmationPageState createState() => _LoanConfirmationPageState();
}

class _LoanConfirmationPageState extends State<LoanConfirmationPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C4B9D),
      appBar: const CustomAppBar(), // Custom app bar

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Card tab bar for navigation
            _buildCardTabBar(),
            const SizedBox(height: 30),
            Expanded(
              child: Row(
                children: [
                  // Left Column (Loan Confirmation)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Centered Image
                        Container(
                          width: 250,
                          height: 250,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/confirm.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Confirmation Text
                        const Text(
                          "Confirmation",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Loan Message
                        const Text(
                          "Please confirm your loan \n  application.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Back Button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                    context); // Go back to the previous screen
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: const BorderSide(
                                    color: Colors.white), // White border
                              ),
                              child: const Text(
                                "Back",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            // Confirm Loan Button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LoanPinPage(), // Ensure this matches your class
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Confirm Loan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: Colors.white.withOpacity(0.4),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),

                  // Right Column (Loan Details)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Loan Details title
                        const Text(
                          "Loan Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Row 1: Business Name and Account Number
                        _buildDetailsRow("Loan Amount", "CDF 30,000",
                            "Repayment Date", "18.08.2024"),

                        const SizedBox(height: 16),

                        // Row 2: Loan Amount and Transaction Fee
                        _buildDetailsRow("Interest", "10 %",
                            "Repayment Amount", "CDF 500"),

                        const SizedBox(height: 16),

                        // Row 3: Loan Recipient Account
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Loan Recipient Amount",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "123 456 5789",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Final loan conditions card
                        const Card(
                          color: Color(0xFF4C6DB2),
                          margin: EdgeInsets.only(top: 16),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Final loan conditions will be specified when the application is approved.",
                              style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Footer(), // Footer widget
          ],
        ),
      ),
    );
  }

  // Build individual tab for the card tab bar
  Widget _buildCardTab(String title, int index) {
    final isSelected =
        _selectedTabIndex == index; // Check if the tab is selected

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index; // Update the selected tab index
        });

        // Navigate to the appropriate screen when the tab is clicked
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoansPage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyLoansPage()),
          );
        } else {
          print("hello jeff");
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF3C4B9D)
                  : Colors.white, // Change color if selected
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal, // Bold if selected
              decoration: TextDecoration.none, // Remove underline
            ),
          ),
          // Line below the text if the tab is selected
          if (isSelected)
            Container(
              height: 2, // Height of the line
              width: 40, // Width of the line
              color: const Color(0xFF3C4B9D), // Color of the line
              margin: const EdgeInsets.only(top: 4), // Margin above the line
            ),
        ],
      ),
    );
  }

  // Build card tab bar for navigation
  Widget _buildCardTabBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCardTab('Apply Loan', 0),
          _buildCardTab('My Loans', 1),
          _buildCardTab('Credit History', 2),
        ],
      ),
    );
  }

  // Build a row for displaying loan details
  Widget _buildDetailsRow(String leftTitle, String leftValue, String rightTitle,
      String rightValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              leftTitle,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              leftValue,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rightTitle,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              rightValue,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
