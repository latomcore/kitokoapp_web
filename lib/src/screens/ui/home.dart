import 'package:flutter/material.dart';
import 'package:kitokopay/service/api_client_helper_utils.dart';
import 'package:kitokopay/src/customs/atmcarditem.dart';
import 'package:kitokopay/src/customs/footer.dart';
import 'package:kitokopay/src/screens/ui/loans.dart';
import 'package:kitokopay/src/customs/appbar.dart';
import 'package:kitokopay/src/screens/utils/resposive_layout.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:kitokopay/src/screens/utils/session_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstName = 'User';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    GlobalSessionManager().startMonitoring(context);
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginDetailsStr = prefs.getString('loginDetails');

    if (loginDetailsStr != null) {
      ElmsSSL elmsSSL = ElmsSSL();
      final parsedLogin = elmsSSL.cleanResponse(loginDetailsStr);

      setState(() {
        firstName = parsedLogin['Data']['FirstName'] ?? 'User';
        lastName = parsedLogin['Data']['LastName'] ?? '';
      });
    }
  }

  Future<Map<String, dynamic>> _getTransactionsAndCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loanDetailsStr = prefs.getString('loanDetails');
    String? loginDetailsStr = prefs.getString('loginDetails');

    ElmsSSL elmsSSL = ElmsSSL();

    if (loginDetailsStr == null) {
      // Return default values if login details are null
      return {
        "transactions": <Map<String, dynamic>>[], // Empty list for transactions
        "currency": "N/A",
        "limit": "0",
      };
    }

    final parsedLogin = elmsSSL.cleanResponse(loginDetailsStr);

    String currency = parsedLogin['Data']['Currency'] ?? "N/A";
    String limit = parsedLogin['Data']['LimitAmount']?.toString() ?? "0";

    // If loanDetailsStr is null, return empty transactions with currency and limit
    if (loanDetailsStr == null) {
      return {
        "transactions": <Map<String, dynamic>>[], // Empty list for transactions
        "currency": currency,
        "limit": limit,
      };
    }

    try {
      final parsedResult = elmsSSL.cleanResponse(loanDetailsStr);

      String transactionsStr = parsedResult['Data']['Transactions'] ?? "[]";

      List<dynamic> rawTransactions = jsonDecode(transactionsStr);
      List<Map<String, dynamic>> transactionsList = rawTransactions
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      return {
        "transactions": transactionsList,
        "currency": currency,
        "limit": limit,
      };
    } catch (e) {
      return {
        "transactions": <Map<String, dynamic>>[], // Return empty list on error
        "currency": currency,
        "limit": limit,
      };
    }
  }

  String formatNumber(String number) {
    try {
      final value = int.parse(number);
      return NumberFormat.decimalPattern().format(value);
    } catch (e) {
      return number;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: CustomAppBar(),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => GlobalSessionManager().updateActivity(context),
        child: Stack(
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
            FutureBuilder<Map<String, dynamic>>(
              future: _getTransactionsAndCurrency(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Failed to load data',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final currency = snapshot.data!['currency'] as String;
                final limit = snapshot.data!['limit'] as String;
                final formattedLimit = formatNumber(limit);

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Welcome message
                            Text(
                              'Welcome, $firstName $lastName',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Cards Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Your Cards',
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
                            const SizedBox(height: 10),
                            ResponsiveLayout(
                              tiny: Column(
                                children: [
                                  CardItem(
                                    loanLimit: formattedLimit,
                                    currency: currency,
                                    isSelected: false,
                                    onSelect: () {},
                                  ),
                                ],
                              ),
                              tablet: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: CardItem(
                                      loanLimit: formattedLimit,
                                      currency: currency,
                                      isSelected: false,
                                      onSelect: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: CardItem(
                                      loanLimit: formattedLimit,
                                      currency: currency,
                                      isSelected: false,
                                      onSelect: () {},
                                    ),
                                  ),
                                ],
                              ),
                              computer: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: CardItem(
                                      loanLimit: formattedLimit,
                                      currency: currency,
                                      isSelected: false,
                                      onSelect: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: CardItem(
                                      loanLimit: formattedLimit,
                                      currency: currency,
                                      isSelected: false,
                                      onSelect: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: CardItem(
                                      loanLimit: formattedLimit,
                                      currency: currency,
                                      isSelected: false,
                                      onSelect: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Quick Services
                            const Text(
                              'Quick Services',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ResponsiveLayout(
                              tiny: Row(
                                children: [
                                  Flexible(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoansPage(),
                                          ),
                                        );
                                      },
                                      child: _buildQuickServiceCard(
                                        color: const Color(0xFF7FC1E4),
                                        icon: Icons.money,
                                        title: 'Get Loan',
                                        description:
                                            'Get unsecured personal loan',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              tablet: Row(
                                children: [
                                  Flexible(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoansPage(),
                                          ),
                                        );
                                      },
                                      child: _buildQuickServiceCard(
                                        color: const Color(0xFF7FC1E4),
                                        icon: Icons.money,
                                        title: 'Get Loan',
                                        description:
                                            'Get unsecured personal loan',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: _buildAddCardPlaceholder(),
                                  ),
                                ],
                              ),
                              computer: Row(
                                children: [
                                  Flexible(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoansPage(),
                                          ),
                                        );
                                      },
                                      child: _buildQuickServiceCard(
                                        color: const Color(0xFF7FC1E4),
                                        icon: Icons.money,
                                        title: 'Get Loan',
                                        description:
                                            'Get unsecured personal loan',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: _buildAddCardPlaceholder(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Recent Transactions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7FC1E4),
                                  ),
                                  onPressed: () {},
                                  child: const Text('Recent Transactions'),
                                ),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'Loans',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              color: const Color(0xFF4564A8),
                              height: 300,
                              child: _buildTransactionList(),
                            ),
                          ],
                        ),
                      ),
                      const Footer(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickServiceCard({
    required Color color,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardPlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 24, color: Colors.white),
          SizedBox(height: 10),
          Text(
            'Add Card',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add another virtual card',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getTransactionsAndCurrency(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No transactions available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final transactions =
            snapshot.data!['transactions'] as List<Map<String, dynamic>>;
        final currency = snapshot.data!['currency'] as String;

        // Check if the transactions list is empty
        if (transactions.isEmpty) {
          return const Center(
            child: Text(
              'No transactions available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Currency: $currency',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: transactions.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return ListTile(
                    leading: Icon(
                      transaction['type'] == 'Disbursement'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    title: Text(
                      transaction['type'] ?? 'Transaction',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      transaction['date'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$currency ${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          transaction['receiptnumber'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom Painter for drawing wavy lines
class WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += 20) {
      final path = Path();
      path.moveTo(0, y);
      path.quadraticBezierTo(
          size.width / 2, y + 10, size.width, y); // Draw wavy line
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
