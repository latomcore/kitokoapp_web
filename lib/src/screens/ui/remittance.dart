import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:kitokopay/src/customs/appbar.dart';
import 'package:kitokopay/src/customs/atmcarditem.dart';
import 'package:kitokopay/src/customs/footer.dart';
import 'package:kitokopay/src/screens/ui/remittance/remittance_page.dart';
import 'package:kitokopay/src/screens/ui/remittance/transactions/transactions.dart'; // Adjust the import as necessary

class RemittancePage extends StatefulWidget {
  const RemittancePage({super.key});

  @override
  _RemittancePageState createState() => _RemittancePageState();
}

class _RemittancePageState extends State<RemittancePage> {
  String selectedCountry = 'Select Country';
  String selectedOption = 'Select Payment Method';
  int selectedCardIndex = -1;
  int _selectedTabIndex = 0;
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final Map<String, List<String>> paymentOptions = {
    'Kenya': ['Safaricom', 'Airtel Money', 'M-Pesa'],
    'Uganda': ['MTN', 'Airtel Money'],
    'Tanzania': ['Vodacom', 'Airtel Money'],
    'Rwanda': ['MTN', 'Airtel Money'],
  };

  void onCardSelect(int index) {
    setState(() {
      selectedCardIndex = index;
    });
  }

  void onContinue() {
    if (recipientNameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        selectedCountry == 'Select Country') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields before continuing.'),
        ),
      );
    } else {
      // Handle the continue action
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const RemittancePageDetails()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: const Color(0xFF3C4B9D),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Updated
          children: [
            _buildCardTabBar(),
            _buildCardSelection(),
            Expanded(
              child: Row(
                children: [
                  _buildRecipientDetailsColumn(),
                  const SizedBox(width: 16),
                  _buildSearchRecipientColumn(),
                ],
              ),
            ),
            const Footer(), // Footer at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildCardTabBar() {
    return Card(
      color: Colors.lightBlue,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCardTab('Send Money', 0),
            _buildCardTab('Transactions', 1),
            _buildCardTab('Manage Recipients', 2),
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

  Widget _buildCardSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
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
    );
  }

  Widget _buildRecipientDetailsColumn() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recipient's Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            _buildCountryPicker(),
            const SizedBox(height: 20),
            _buildOperatorDropdown(),
            const SizedBox(height: 20),
            _buildTextField("Recipient Name", recipientNameController,
                'Recipient Name', true),
            const SizedBox(height: 20),
            _buildTextField("Phone Number", phoneNumberController,
                'Recipient Phone Number', false),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onContinue,
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
    );
  }

  Widget _buildCountryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recipient's Country",
            style: TextStyle(color: Colors.white)),
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              onSelect: (Country country) {
                setState(() {
                  selectedCountry = country.name;
                  selectedOption = 'Select Payment Method';
                });
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(selectedCountry,
                    style: const TextStyle(color: Colors.white)),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOperatorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recipient Operator", style: TextStyle(color: Colors.white)),
        DropdownButton<String>(
          value: selectedOption,
          items: _getPaymentOptions()
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          dropdownColor: const Color(0xFF3C4B9D),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedOption = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  List<String> _getPaymentOptions() {
    return paymentOptions[selectedCountry] ?? ['Select Payment Method'];
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String hintText, bool isSearch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.white),
            ),
            suffixIcon:
                isSearch ? const Icon(Icons.search, color: Colors.white) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRecipientColumn() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Recipient',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Favourites',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          // Business Cards Row
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(Icons.person_2_outlined,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Jeff dev',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(Icons.person_2_outlined,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kim dev',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(Icons.person_2_outlined,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hilda dev',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Colors.white,
                          style: BorderStyle.solid,
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add Recipient',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Account Search Field
          TextField(
            decoration: InputDecoration(
              hintText: 'Search Recipient',
              hintStyle: const TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Colors.white,
                ),
              ),
              suffixIcon: const Icon(Icons.search, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          // Business List
          Card(
            color: const Color(0xFF4564A8),
            child: Column(
              children: [
                businessListItem(
                    Icons.person_2_outlined, 'Jeff dev', '456878', 'USD'),
                const Divider(color: Colors.white),
                businessListItem(
                    Icons.person_2_outlined, 'Kim dev', '8080808', 'USD'),
                const Divider(color: Colors.white),
                businessListItem(
                    Icons.person_2_outlined, 'Kings Dev', '0038383', 'USD'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget businessListItem(
      IconData icon, String businessName, String loanLimit, String currency) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            businessName,
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          Text(
            '$currency $loanLimit',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
