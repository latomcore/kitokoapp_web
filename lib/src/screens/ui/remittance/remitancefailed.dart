import 'package:flutter/material.dart';
import 'package:kitokopay/src/customs/appbar.dart';
import 'package:kitokopay/src/customs/footer.dart';
import 'package:kitokopay/src/screens/ui/home.dart';
import 'package:kitokopay/src/screens/ui/remittance.dart';
import 'package:kitokopay/src/screens/ui/remittance/transactions/transactions.dart';

class RemittanceFailedPage extends StatefulWidget {
  const RemittanceFailedPage({super.key});

  @override
  State<RemittanceFailedPage> createState() => _RemittanceFailedPageState();
}

class _RemittanceFailedPageState extends State<RemittanceFailedPage> {
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
            _buildCardTabBar(), // Tab bar for navigation
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  // Left Column (Remittance Failed)
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
                              image: AssetImage('assets/images/failed.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Failed Text
                        const Text(
                          "Failed!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Failure Message
                        const Text(
                          "Your transaction could not be completed.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Status text
                        const Text(
                          "Status:",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Status Card
                        const Card(
                          color: Color(0xFF4C6DB2),
                          margin: EdgeInsets.only(top: 16),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "You do not have sufficient balance to complete this transaction.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Done Button
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to home screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(color: Colors.white),
                          ),
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

                  // Right Column (Remittance Details)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Remittance Details title
                        const Text(
                          "Transaction Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Row 1: Amount and Date
                        _buildDetailsRow(
                            "Recipient", "Mike Madilu", "Country", "DRC"),

                        const SizedBox(height: 16),

                        // Row 3: Recipient Account
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recipient Operator",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Airtel Mobile Money",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Row 2: Interest and Fee
                        _buildDetailsRow(
                            "Amount", "CDF 30,000", "Transfer Fee", "CDF 500"),

                        const SizedBox(height: 16),

                        // Row 3: Recipient Account
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Virtual Card Account",
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

                        // Final card with payment conditions
                        // const Card(
                        //   color: Color(0xFF4C6DB2),
                        //   margin: EdgeInsets.only(top: 16),
                        //   child: Padding(
                        //     padding: EdgeInsets.all(16.0),
                        //     child: Text(
                        //       "All remittances must adhere to the established Terms and Conditions.",
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontStyle: FontStyle.italic,
                        //       ),
                        //     ),
                        //   ),
                        // ),
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
            MaterialPageRoute(builder: (context) => const RemittancePage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TransactionsPage()),
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
        borderRadius:
            BorderRadius.circular(12.0), // Rounded corners for the tab bar
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread tabs evenly
        children: [
          _buildCardTab('Initiate Remittance', 0),
          _buildCardTab('History', 1),
          _buildCardTab('Settings', 2),
        ],
      ),
    );
  }

  // Function to build the card details row
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              leftValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rightTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              rightValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
