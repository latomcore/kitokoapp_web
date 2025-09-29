import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:kitokopay/src/screens/auth/login.dart';
// Assuming a Register screen exists
import 'package:kitokopay/service/api_client_helper_utils.dart'; // Import the ElmsSSL class

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  Country? _selectedCountry;
  bool _isLoading = false;
  String? _errorMessage;

  // Format phone number with country code
  String formatPhoneNumber(String countryCode, String phoneNumber) {
    String formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return '$countryCode$formattedPhoneNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Row(
            children: [
              // Left Column (Image)
              if (isWideScreen)
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.black,
                    child: Image.asset(
                      'assets/images/otp.png', // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              // Right Column (OTP Form)
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Center(
                            child: Image.asset(
                              'assets/images/Kitokopaylogo.png',
                              width: 120,
                              height: 120,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Phone Number Input
                          const Text(
                            "Phone Number",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showCountryPicker(
                                    context: context,
                                    showPhoneCode: true,
                                    onSelect: (Country country) {
                                      setState(() {
                                        _selectedCountry = country;
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _selectedCountry?.flagEmoji ?? '🌍',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "+${_selectedCountry?.phoneCode ?? '254'}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength:
                                      10, // Limit phone number to 10 digits
                                  decoration: InputDecoration(
                                    hintText: "Enter phone number",
                                    counterText:
                                        "", // Hides the character count
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // OTP Input
                          const Text(
                            "OTP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6, // Limit OTP to 6 digits
                            decoration: InputDecoration(
                              hintText: "Enter OTP",
                              counterText: "", // Hides the character count
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Error Message
                          if (_errorMessage != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          // Loading Indicator
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator()),
                          // Verify Button
                          Center(
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      String phoneNumber =
                                          _phoneController.text.trim();
                                      String otp = _otpController.text.trim();

                                      if (_selectedCountry == null ||
                                          phoneNumber.isEmpty ||
                                          otp.isEmpty) {
                                        setState(() {
                                          _errorMessage =
                                              "All fields are required!";
                                        });
                                        return;
                                      }

                                      String formattedPhoneNumber =
                                          formatPhoneNumber(
                                              _selectedCountry?.phoneCode ??
                                                  '254',
                                              phoneNumber);

                                      setState(() {
                                        _isLoading = true;
                                        _errorMessage = null;
                                      });

                                      try {
                                        ElmsSSL elmsSSL = ElmsSSL();

                                        // Make API call to activate with phone number and OTP
                                        String response =
                                            await elmsSSL.activate(
                                                formattedPhoneNumber, otp);

                                        // Decode the response
                                        Map<String, dynamic> resultMap =
                                            jsonDecode(response);

                                        // Check API response status
                                        if (resultMap['status'] == 'success') {
                                          String message =
                                              resultMap['message'] ??
                                                  'Activation successful!';

                                          // Show success dialog
                                          showDialog(
                                            context: context,
                                            barrierDismissible:
                                                false, // Prevent dismissing the dialog by tapping outside
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text("Success"),
                                                content: Text(message),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      // Navigate to login screen
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LoginScreen(),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text("OK"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          // Display error message from API response
                                          setState(() {
                                            _errorMessage =
                                                resultMap['message'] ??
                                                    'Invalid OTP!';
                                          });
                                        }
                                      } catch (e) {
                                        // Handle any exceptions or errors
                                        setState(() {
                                          _errorMessage =
                                              'An error occurred: $e';
                                        });
                                      } finally {
                                        // Ensure loading state is updated
                                        setState(() => _isLoading = false);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                padding: EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: isWideScreen ? 200 : 50,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                "Verify",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Links for Login and Register
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Already have an account? Log in",
                                    style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
