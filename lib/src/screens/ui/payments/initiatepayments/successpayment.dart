import 'package:flutter/material.dart';
import 'package:kitokopay/src/customs/appbar.dart';
import 'package:kitokopay/src/customs/footer.dart';
import 'package:kitokopay/src/screens/ui/home.dart';
import 'package:kitokopay/src/screens/ui/payments.dart';
import 'package:kitokopay/src/screens/ui/payments/payment/payment.dart';

class SuccessPaymentPage extends StatefulWidget {
  const SuccessPaymentPage({super.key});

  @override
  State<SuccessPaymentPage> createState() => _SuccessPaymentPageState();
}

class _SuccessPaymentPageState extends State<SuccessPaymentPage> {
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
                  // Left Column (Payment Success)
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
                              image: AssetImage('assets/images/succes.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Success Text
                        const Text(
                          "Payment Successful!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Confirmation Message
                        const Text(
                          "Your payment has been processed.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),

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

                  // Right Column (Payment Details)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Payment Details title
                        const Text(
                          "Payment Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Row 1: Business Name and Account Number
                        _buildDetailsRow(
                          "Business Name",
                          "Apple Store",
                          "Account Number",
                          "987654",
                        ),

                        const SizedBox(height: 16),

                        // Row 2: Amount and Transaction Fee
                        _buildDetailsRow(
                          "Amount",
                           "CDF 500000",
                          "Transaction Fee",
                          "CDF 500",
                        ),

                        const SizedBox(height: 16),

                        // Virtual Card Account
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
                        const Card(
                          color: Color(0xFF4C6DB2),
                          margin: EdgeInsets.only(top: 16),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "All payments must strictly adhere to the established payment Terms and Conditions.",
                              style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),

                        // Thin horizontal white line
                        const Divider(color: Colors.white, thickness: 1),

                        // Row with share and download options
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              "Share",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Share button with icon
                            Card(
                              color: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.share_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            // Download text and icon
                            const Text(
                              "Download",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Download button with icon
                            Card(
                              color: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.download_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
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
            MaterialPageRoute(builder: (context) => const PaymentPage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaymentScreen()),
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
          _buildCardTab('Initiate Payments', 0),
          _buildCardTab('Payments', 1),
          _buildCardTab('Manage Favourites', 2),
        ],
      ),
    );
  }

// Build a row for displaying payment details
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
