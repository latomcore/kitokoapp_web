import 'package:flutter/material.dart';
import 'package:kitokopay/src/customs/appbar.dart';
import 'package:kitokopay/src/customs/footer.dart';
import 'package:kitokopay/src/screens/ui/payments.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int _selectedTabIndex = 0;
  int _selectedCardIndex = -1; // For tracking the selected card

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
                  // Left Column (Payments Title and Cards)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payments",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentCard(0, 'CDF 64,000', '1 June 2024'),
                        const SizedBox(height: 10),
                        _buildPaymentCard(1, 'CDF 75,000', '5 July 2024'),
                        const SizedBox(height: 10),
                        _buildPaymentCard(2, 'CDF 55,000', '10 August 2024'),
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
                        // const Card(
                        //   color: Color(0xFF4C6DB2),
                        //   margin: EdgeInsets.only(top: 16),
                        //   child: Padding(
                        //     padding: EdgeInsets.all(16.0),
                        //     child: Text(
                        //       "All payments must strictly adhere to the established payment Terms and Conditions.",
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontStyle: FontStyle.italic,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const Divider(color: Colors.white, thickness: 1),
                        // const SizedBox(height: 16),
                        // Row(
                        //   children: [
                        //     const Text(
                        //       "Share",
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontSize: 16,
                        //       ),
                        //     ),
                        //     const SizedBox(width: 8),
                        //     Card(
                        //       color: Colors.lightBlue,
                        //       shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(5)),
                        //       child: const Padding(
                        //         padding: EdgeInsets.all(4.0),
                        //         child: Icon(
                        //           Icons.share_outlined,
                        //           color: Colors.white,
                        //           size: 20,
                        //         ),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 20),
                        //     const Text(
                        //       "Download",
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontSize: 16,
                        //       ),
                        //     ),
                        //     const SizedBox(width: 8),
                        //     Card(
                        //       color: Colors.lightBlue,
                        //       shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(5)),
                        //       child: const Padding(
                        //         padding: EdgeInsets.all(4.0),
                        //         child: Icon(
                        //           Icons.download_outlined,
                        //           color: Colors.white,
                        //           size: 20,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
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

  // Build payment card with selectable functionality
  Widget _buildPaymentCard(int index, String amount, String date) {
    final isSelected = _selectedCardIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCardIndex = index;
        });
      },
      child: Card(
        color: const Color(0xFF4564A8),
        shape: isSelected
            ? RoundedRectangleBorder(
                side: const BorderSide(color: Colors.lightBlue, width: 2.0),
                borderRadius: BorderRadius.circular(10),
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text(
              //   'Amount Borrowed',
              //   style: TextStyle(
              //     fontWeight: FontWeight.w600,
              //     color: Colors.white,
              //   ),
              // ),
              // const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(color: Colors.white),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7FC1E4),
                    ),
                    child: const Text(
                      'Success',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaction Date:',
                    style: TextStyle(color: Colors.white),
                  ),
                  Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build individual tab for the card tab bar
  Widget _buildCardTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
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
              color: isSelected ? const Color(0xFF3C4B9D) : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
          if (isSelected)
            Container(
              height: 2,
              width: 40,
              color: const Color(0xFF3C4B9D),
              margin: const EdgeInsets.only(top: 4),
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
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              leftValue,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rightTitle,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              rightValue,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
