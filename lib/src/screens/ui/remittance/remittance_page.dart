import 'package:flutter/material.dart';
import 'package:kitokopay/src/customs/appbar.dart';
import 'package:kitokopay/src/customs/atmcarditem.dart';
import 'package:kitokopay/src/customs/footer.dart';
import 'package:kitokopay/src/customs/t-shaped.dart';
import 'package:kitokopay/src/screens/ui/remittance.dart';
import 'package:kitokopay/src/screens/ui/remittance/remittanceConfirmation.dart';
import 'package:kitokopay/src/screens/ui/remittance/transactions/transactions.dart';

class RemittancePageDetails extends StatefulWidget {
  const RemittancePageDetails({super.key});

  @override
  State<RemittancePageDetails> createState() => _RemittancePageDetailsState();
}

class _RemittancePageDetailsState extends State<RemittancePageDetails> {
  static const Color _primaryColor = Color(0xFF3C4B9D);
  static const Color _secondaryColor = Colors.lightBlue;

  final TextEditingController _recipientTransactionController =
      TextEditingController();
  final TextEditingController _sendersTransactionController =
      TextEditingController();
  final TextEditingController _transactionPurpose = TextEditingController();

  String _selectedOption = 'Select Payment Method';
  int _selectedCardIndex = -1;
  int _selectedTabIndex = 0;
  String _selectedCurrency = 'Select Currency';

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'US Dollar'},
    {'code': 'EUR', 'name': 'Euro'},
    {'code': 'GBP', 'name': 'British Pound'},
    {'code': 'JPY', 'name': 'Japanese Yen'},
    {'code': 'AUD', 'name': 'Australian Dollar'},
    {'code': 'CAD', 'name': 'Canadian Dollar'},
    {'code': 'CHF', 'name': 'Swiss Franc'},
    {'code': 'CNY', 'name': 'Chinese Yuan'},
  ];

  final Map<String, List<String>> _paymentOptions = {
    'USD': ['Bank Transfer', 'Wire Transfer', 'Digital Wallet'],
    'EUR': ['SEPA', 'Wire Transfer', 'Digital Wallet'],
    'GBP': ['BACS', 'CHAPS', 'Digital Wallet'],
    'JPY': ['Bank Transfer', 'Digital Wallet'],
    'AUD': ['NPP', 'BPAY', 'Digital Wallet'],
    'CAD': ['Interac', 'Wire Transfer', 'Digital Wallet'],
    'CHF': ['Bank Transfer', 'Digital Wallet'],
    'CNY': ['UnionPay', 'Alipay', 'WeChat Pay'],
  };

  @override
  void dispose() {
    _recipientTransactionController.dispose();
    _sendersTransactionController.dispose();
    _transactionPurpose.dispose();
    super.dispose();
  }

  void _onCardSelect(int index) {
    setState(() {
      _selectedCardIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: _primaryColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCardTabBar(),
            _buildCardSelection(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(child: _buildTransactionDetailsColumn()),
                    const TSeparator(),
                    const SizedBox(width: 16),
                    // Expanded(child: _buildSearchRecipientColumn()),
                  ],
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTabBar() {
    return Card(
      color: _secondaryColor,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTab('Send Money', 0),
            _buildTab('Transactions', 1),
            _buildTab('Manage Recipients', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });

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

  Widget _buildCardSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 10,
                right: index == 2 ? 0 : 10,
              ),
              child: CardItem(
                loanLimit: '${10000 - (index * 2500)}',
                currency: 'CDF',
                isSelected: _selectedCardIndex == index,
                onSelect: () => _onCardSelect(index),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTransactionDetailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Transaction Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        _buildCurrencySelector(),
        const SizedBox(height: 20),
        _buildOperatorDropdown(),
        const SizedBox(height: 20),
        _buildTransactionPurposeField(),
        const SizedBox(height: 20),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildTransactionPurposeField() {
    return TextField(
      controller: _transactionPurpose,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Purpose of funds transfer",
        hintStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RemittanceConfirmationPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _secondaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Currency",
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCurrency,
          dropdownColor: _primaryColor,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
          items: [
            const DropdownMenuItem(
              value: 'Select Currency',
              child: Text(
                'Select Currency',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ..._currencies.map<DropdownMenuItem<String>>((currency) {
              return DropdownMenuItem<String>(
                value: currency['code'],
                child: Text(
                  currency['name']!,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCurrency = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOperatorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Payment Method",
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedOption ?? 'Select Payment Method', // Provide default
          dropdownColor: _primaryColor,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
          items: (_paymentOptions[_selectedCurrency] ?? []).map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(
                method,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedOption = value ?? ''; // Handle null case
            });
          },
        ),
      ],
    );
  }

  // Widget _buildSearchRecipientColumn() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "Search Recipient",
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //             fontSize: 18,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         TextField(
  //           controller: _recipientTransactionController,
  //           style: const TextStyle(color: Colors.white),
  //           decoration: InputDecoration(
  //             hintText: "Enter recipient",
  //             hintStyle: const TextStyle(color: Colors.white),
  //             filled: true,
  //             fillColor: Colors.transparent,
  //             enabledBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(8.0),
  //               borderSide: const BorderSide(color: Colors.white),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(8.0),
  //               borderSide: const BorderSide(color: Colors.white, width: 2),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         _buildTransferRateSection(),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTransferRateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transfer Rate',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'You send - €270',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First column with GBP, dots, and CDF
            Column(
              children: [
                // GBP Chip at the top
                Chip(
                  label: const Text(
                    "GBP",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  backgroundColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 20),
                // Dots with vertical line
                Column(
                  children: [
                    Container(
                      width: 2, // Vertical line width
                      height: 160, // Total height of dots and spacing
                      color: Colors.white, // Line color
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // CDF Chip at the bottom
                Chip(
                  label: const Text(
                    "CDF",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  backgroundColor: Colors.grey.shade300,
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Cards beside dots
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSmallCard("jeff"),
                  const SizedBox(height: 20),
                  _buildSmallCard("kim"),
                  const SizedBox(height: 20),
                  _buildSmallCard("hilda"),
                  const SizedBox(height: 20),
                  _buildSmallCard("Kings"),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Jeff is a text that is white bold',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // Small cards beside progress dots
  Widget _buildSmallCard(String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
