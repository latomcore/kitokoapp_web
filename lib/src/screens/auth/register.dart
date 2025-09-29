import 'package:flutter/material.dart';
import 'package:kitokopay/src/screens/auth/login.dart';
import 'package:kitokopay/service/api_client_helper_utils.dart'; // Import the ElmsSSL class
import 'package:country_picker/country_picker.dart';
import 'dart:convert';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  Country? _selectedCountry; // To store the selected country
  bool _isLoading = false; // Track loading state
  String _errorMessage = ''; // Track error messages

  // Method to format phone number by removing spaces or non-numeric characters
  String getFormattedPhoneNumber(String phone) {
    return phone.replaceAll(
        RegExp(r'[^0-9]'), ''); // Remove non-numeric characters
  }

  // Method to handle registration logic
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous errors
    });

    String phoneNumber = _phoneController.text;

    // Combine country code and phone number, ensuring no leading "+"
    String fullPhoneNumber =
        '${_selectedCountry?.phoneCode ?? '254'}${getFormattedPhoneNumber(phoneNumber)}';

    try {
      // Call getCustomer function from ElmsSSL class
      ElmsSSL elmsSSL = ElmsSSL(); // Create an instance of ElmsSSL
      String result = await elmsSSL.getCustomer(fullPhoneNumber);

      // Check if the registration is successful
      Map<String, dynamic> resultMap = jsonDecode(result);
      if (resultMap['status'] == 'success') {
        // If the request is successful, navigate to the LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        // Handle error message from response
        setState(() {
          _errorMessage = resultMap['message'] ?? 'Invalid details!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Row(
            children: [
              // Left column with image - larger on wider screens
              if (isWideScreen)
                Expanded(
                  flex: 3, // Increased flex for the image
                  child: Container(
                    color: Colors.grey[200],
                    child: Image.asset(
                      'assets/images/register.png', // Replace with your image asset
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),

              // Right column with form
              Expanded(
                flex: 2, // Adjusted flex for the form
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 400 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo Image
                          Center(
                            child: Image.asset(
                              'assets/images/Kitokopaylogo.png', // Replace with your logo asset
                              width: 120,
                              height: 120,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Welcome Text
                          const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle Text
                          const Text(
                            "Enter your phone number to create an account and \nget started",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Country Label
                          const Text(
                            "Country",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),

                          // Country Picker
                          GestureDetector(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: true,
                                onSelect: (Country country) {
                                  setState(() {
                                    _selectedCountry = country;
                                  });

                                  // Prepend the country code to the phone number if not already included
                                  String currentPhone = _phoneController.text;
                                  if (currentPhone.isNotEmpty &&
                                      !currentPhone.startsWith(
                                          "+${country.phoneCode}")) {
                                    _phoneController.text =
                                        "+${country.phoneCode}$currentPhone";
                                  }
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(_selectedCountry?.flagEmoji ?? '🌍'),
                                  const SizedBox(width: 8),
                                  Text("+${_selectedCountry?.phoneCode ?? ''}"),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Phone Number Text Field
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "Enter your phone number",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Register Now Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      "Register Now",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Already have an account? Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  " Log In",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
