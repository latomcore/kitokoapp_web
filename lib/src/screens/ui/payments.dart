import 'package:flutter/material.dart';
import 'package:kitokopay/src/customs/appbar.dart';
import 'package:kitokopay/src/customs/atmcarditem.dart';
import 'package:kitokopay/src/customs/footer.dart';
import 'package:kitokopay/src/screens/ui/payments/initiatepayments/paymentconfirmation.dart';
import 'package:kitokopay/src/screens/ui/payments/payment/payment.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int? selectedCardIndex;
  int _selectedTabIndex = 0;

  void onCardSelect(int index) {
    setState(() {
      selectedCardIndex = selectedCardIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // Using the custom app bar
      backgroundColor: const Color(0xFF3C4B9D),
      body: LayoutBuilder(builder: (context, constraints) {
        // Check screen width
        bool isMobile = constraints.maxWidth <= 600;

        return Column(
          children: [
            // Custom Tab Bar
            _buildCardTabBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Choose Card',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CardItem(
                              loanLimit: '10,000',
                              currency: 'CDF',
                              isSelected: selectedCardIndex == 0,
                              onSelect: () => onCardSelect(0),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CardItem(
                              loanLimit: '8,500',
                              currency: 'CDF',
                              isSelected: selectedCardIndex == 1,
                              onSelect: () => onCardSelect(1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CardItem(
                              loanLimit: '5,000',
                              currency: 'CDF',
                              isSelected: selectedCardIndex == 2,
                              onSelect: () => onCardSelect(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Payment and Business Search Columns
                      Row(
                        children: [
                          // Payment Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Payment Merchant',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Pay to',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Please enter account number',
                                    hintStyle:
                                        const TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    suffixIcon: const Icon(Icons.search,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Amount',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Please enter amount',
                                    hintStyle:
                                        const TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PaymentConfirmationPage(),
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
                                    'Continue',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                              color: Colors.white, thickness: 1),
                          // Business Search Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Search Business',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Business Cards Row
                                Row(
                                  children: [
                                    _buildBusinessCard(
                                        'Spotify', Icons.shopping_cart),
                                    const SizedBox(width: 10),
                                    _buildBusinessCard(
                                        'Netflix', Icons.shopping_cart),
                                    const SizedBox(width: 10),
                                    _buildBusinessCard(
                                        'Hulu', Icons.shopping_cart),
                                    const SizedBox(width: 10),
                                    _buildAddBusinessCard(),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Account Search Field
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Please enter account number',
                                    hintStyle:
                                        const TextStyle(color: Colors.white),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    suffixIcon: const Icon(Icons.search,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Business List
                                Card(
                                  color: const Color(0xFF4564A8),
                                  child: Column(
                                    children: [
                                      businessListItem(
                                          Icons.videocam, 'Netchill', '456878'),
                                      const Divider(color: Colors.white),
                                      businessListItem(Icons.store,
                                          'Apple Store', '8080808'),
                                      const Divider(color: Colors.white),
                                      businessListItem(Icons.bike_scooter,
                                          'Jumia', '0038383'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isMobile)
              const Footer(), // Display footer only on larger screens
          ],
        );
      }),
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
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
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
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessCard(String name, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAddBusinessCard() {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: Colors.white, style: BorderStyle.solid, width: 1.0),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text('Add', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget businessListItem(
      IconData icon, String business, String accountNumber) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(business, style: const TextStyle(color: Colors.white)),
      subtitle:
          Text(accountNumber, style: const TextStyle(color: Colors.white)),
    );
  }
}
