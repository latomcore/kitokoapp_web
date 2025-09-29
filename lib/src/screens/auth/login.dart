import 'package:flutter/material.dart';
import 'package:kitokopay/src/screens/ui/home.dart';
import "package:kitokopay/src/screens/auth/otp.dart";
import 'package:kitokopay/service/api_client_helper_utils.dart';
import 'package:country_picker/country_picker.dart';
import 'dart:convert';
import 'package:kitokopay/src/screens/utils/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  Country? _selectedCountry;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isPageLoaded = false; // Track whether the page is loaded

  @override
  void initState() {
    super.initState();
    _simulatePageLoading(); // Simulate page loading
  }

  Future<void> _simulatePageLoading() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate a delay
    setState(() {
      _isPageLoaded = true;
    });
  }

  String getFormattedPhoneNumber(String phone) {
    return phone.replaceAll(
        RegExp(r'[^0-9]'), ''); // Remove non-numeric characters
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isPageLoaded
          ? LayoutBuilder(
              builder: (context, constraints) {
                bool isWideScreen = constraints.maxWidth > 600;

                return Row(
                  children: [
                    if (isWideScreen)
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: Colors.grey[200],
                          child: Image.asset(
                            'assets/images/login.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isWideScreen ? 400 : double.infinity,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Image.asset(
                                    'assets/images/Kitokopaylogo.png',
                                    width: 120,
                                    height: 120,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Welcome Back",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                const Text("Phone Number",
                                    style: TextStyle(fontSize: 16)),
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
                                            String currentPhone =
                                                _phoneController.text;
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
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(_selectedCountry?.flagEmoji ??
                                                '🌍'),
                                            const SizedBox(width: 8),
                                            Text(
                                              "+${_selectedCountry?.phoneCode ?? ''}",
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.number,
                                        maxLength: 10,
                                        decoration: InputDecoration(
                                          counterText: "",
                                          hintText: "Enter your phone number",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Text("PIN",
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _pinController,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: "Enter your PIN",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                if (_isLoading)
                                  const Center(
                                      child: CircularProgressIndicator()),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            setState(() {
                                              _isLoading = true;
                                              _errorMessage = null;
                                            });

                                            String phoneNumber =
                                                _phoneController.text;
                                            String pin = _pinController.text;
                                            String fullPhoneNumber =
                                                '${_selectedCountry?.phoneCode ?? '254'}${getFormattedPhoneNumber(phoneNumber)}';

                                            if (fullPhoneNumber.isEmpty ||
                                                pin.isEmpty) {
                                              setState(() {
                                                _isLoading = false;
                                                _errorMessage =
                                                    'Please enter both phone number and PIN';
                                              });
                                              return;
                                            }

                                            try {
                                              ElmsSSL elmsSSL = ElmsSSL();
                                              String result = await elmsSSL
                                                  .login(pin, fullPhoneNumber);
                                              Map<String, dynamic> resultMap =
                                                  jsonDecode(result);

                                              if (resultMap['status'] ==
                                                  'success') {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await prefs.setInt(
                                                    'sessionStartTime',
                                                    DateTime.now()
                                                        .millisecondsSinceEpoch);

                                                // Start session timeout watcher
                                                GlobalSessionManager()
                                                    .startMonitoring(context);

                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const HomeScreen()),
                                                );
                                              } else {
                                                setState(() {
                                                  _errorMessage =
                                                      resultMap['message'] ??
                                                          'Invalid details!';
                                                });
                                              }
                                            } catch (e) {
                                              setState(() {
                                                _errorMessage =
                                                    'An error occurred: $e';
                                              });
                                            } finally {
                                              setState(
                                                  () => _isLoading = false);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(16),
                                      backgroundColor: Colors.lightBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Log In",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "Don't have an account?",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const OtpPage(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            " Activate account",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
