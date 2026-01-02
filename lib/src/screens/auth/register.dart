import 'package:flutter/material.dart';
import 'package:kitokopay/src/screens/auth/login.dart';
import 'package:kitokopay/src/screens/auth/otp.dart';
import 'package:kitokopay/service/api_client_helper_utils.dart';
import 'package:country_picker/country_picker.dart';
import 'dart:convert';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with SingleTickerProviderStateMixin {
  // Step management
  int _currentStep = 0;
  final int _totalSteps = 4;
  
  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _identificationController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  
  // Form keys for each step
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step4FormKey = GlobalKey<FormState>();
  
  // Focus nodes for keyboard navigation
  final FocusNode _mobileNumberFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final FocusNode _pinFocusNode = FocusNode();
  
  // State variables
  Country? _selectedCountry;
  String? _identificationType;
  String? _verificationMode;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePin = true;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Identification types
  final List<String> _identificationTypes = ['ID', 'Passport', 'Driving License', 'Other'];
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _identificationController.dispose();
    _organizationController.dispose();
    _departmentController.dispose();
    _employeeCodeController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    _mobileNumberFocusNode.dispose();
    _emailFocusNode.dispose();
    _otpFocusNode.dispose();
    _pinFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  String getFormattedPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }
  
  Future<void> _requestOtp() async {
    if (_verificationMode == null) {
      setState(() {
        _errorMessage = 'Please select a verification mode';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // TODO: Implement OTP request API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      setState(() {
        _isOtpSent = true;
        _errorMessage = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to your ${_verificationMode!.toLowerCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // TODO: Implement OTP verification API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      setState(() {
        _isOtpVerified = true;
        _errorMessage = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP verified successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _submitRegistration() async {
    if (!_step4FormKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      String fullPhoneNumber = '${_selectedCountry?.phoneCode ?? '250'}${getFormattedPhoneNumber(_mobileNumberController.text)}';
      
      // Prepare registration data
      Map<String, dynamic> registrationData = {
        "FirstName": _firstNameController.text.trim(),
        "MiddleName": _middleNameController.text.trim(),
        "LastName": _lastNameController.text.trim(),
        "MobileNumber": fullPhoneNumber,
        "IdentificationType": _identificationType ?? 'ID',
        "Identification": _identificationController.text.trim(),
        "Country": _selectedCountry?.name ?? '',
        "Email": _emailController.text.trim(),
        "Organization": _organizationController.text.trim(),
        "Department": _departmentController.text.trim(),
        "EmployeeCode": _employeeCodeController.text.trim(),
        "VerificationMode": _verificationMode ?? 'Email',
        "OTP": _otpController.text.trim(),
        "PIN": _pinController.text.trim(),
      };
      
      // TODO: Implement full registration API call with all fields
      // For now, using getCustomer as a placeholder
      ElmsSSL elmsSSL = ElmsSSL();
      String result = await elmsSSL.getCustomer(fullPhoneNumber);

      Map<String, dynamic> resultMap = jsonDecode(result);
      if (resultMap['status'] == 'success') {
        if (mounted) {
        Navigator.pushReplacement(
          context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        }
      } else {
        setState(() {
          _errorMessage = resultMap['message'] ?? 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      if (mounted) {
      setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _nextStep() {
    bool isValid = false;
    
    switch (_currentStep) {
      case 0:
        isValid = _step1FormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _step2FormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _step3FormKey.currentState?.validate() ?? false;
        break;
      case 3:
        _submitRegistration();
        return;
    }
    
    if (isValid) {
      setState(() {
        _currentStep++;
        _errorMessage = null;
      });
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
      });
    }
  }
  
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          bool isActive = index == _currentStep;
          bool isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
            children: [
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive
                          ? Colors.blue.shade600
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? Colors.blue.shade600
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                if (index < _totalSteps - 1)
              Expanded(
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.blue.shade600
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildStepLabels() {
    final List<String> labels = [
      'Personal Info',
      'Contact & ID',
      'Employment',
      'Account Setup',
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_totalSteps, (index) {
          bool isActive = index == _currentStep;
          bool isCompleted = index < _currentStep;
          
          return Expanded(
                child: Center(
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive || isCompleted
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isActive || isCompleted
                      ? Colors.blue.shade600
                      : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1PersonalInfo();
      case 1:
        return _buildStep2ContactAndID();
      case 2:
        return _buildStep3Employment();
      case 3:
        return _buildStep4AccountSetup();
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildStep1PersonalInfo() {
    return Form(
      key: _step1FormKey,
                      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
          Text(
            "Enter your personal details:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 24),
          
          // First Name
          _buildTextField(
            controller: _firstNameController,
            label: "First Name",
            hint: "Enter your first name",
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Middle Name
          _buildTextField(
            controller: _middleNameController,
            label: "Middle Name",
            hint: "Enter your middle name (optional)",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          
          // Last Name
          _buildTextField(
            controller: _lastNameController,
            label: "Last Name",
            hint: "Enter your last name",
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Last name is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep2ContactAndID() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Enter your contact and identification details:",
                            style: TextStyle(
              fontSize: 18,
                              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 24),
          
          // Mobile Number
          Text(
            "Mobile Number",
                            style: TextStyle(
                              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                              ),
                              child: Row(
                    mainAxisSize: MainAxisSize.min,
                                children: [
                      Text(_selectedCountry?.flagEmoji ?? '🌍', style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                      Text(
                        "+${_selectedCountry?.phoneCode ?? '250'}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
                                ],
                              ),
                            ),
                          ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _mobileNumberController,
                  focusNode: _mobileNumberFocusNode,
                            keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  maxLength: 10,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                  onChanged: (value) {
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Mobile number is required';
                    }
                    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digitsOnly.length < 9) {
                      return 'Phone number must be at least 9 digits';
                    }
                    if (digitsOnly.length > 10) {
                      return 'Phone number must not exceed 10 digits';
                    }
                    return null;
                  },
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                            decoration: InputDecoration(
                    counterText: "",
                    hintText: "783200510",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey.shade600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Email
          _buildTextField(
            controller: _emailController,
            label: "Email",
            hint: "Enter your email address",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Identification Type
          Text(
            "Identification Type",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _identificationType,
            decoration: InputDecoration(
              hintText: "Select identification type",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              prefixIcon: Icon(Icons.badge_outlined, color: Colors.grey.shade600),
            ),
            items: _identificationTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _identificationType = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an identification type';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Identification Number
          _buildTextField(
            controller: _identificationController,
            label: "Identification Number",
            hint: "Enter your identification number",
            icon: Icons.credit_card_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Identification number is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep3Employment() {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Enter your employment details:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 24),

          // Organization
          _buildTextField(
            controller: _organizationController,
            label: "Organization",
            hint: "Enter your organization name",
            icon: Icons.business_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Organization is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Department
          _buildTextField(
            controller: _departmentController,
            label: "Department",
            hint: "Enter your department",
            icon: Icons.work_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Department is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Employee Code
          _buildTextField(
            controller: _employeeCodeController,
            label: "Employee Code",
            hint: "Enter your employee code",
            icon: Icons.badge_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Employee code is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep4AccountSetup() {
    return Form(
      key: _step4FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Set up your account:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 24),
          
          // Verification Mode
          Text(
            "Verification Mode",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _verificationMode,
            decoration: InputDecoration(
              hintText: "Select verification mode",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              prefixIcon: Icon(Icons.verified_user_outlined, color: Colors.grey.shade600),
            ),
            items: ['Email', 'Phone'].map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(mode),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _verificationMode = value;
                _isOtpSent = false;
                _isOtpVerified = false;
                _otpController.clear();
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a verification mode';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Request OTP Button
          if (_verificationMode != null && !_isOtpSent)
                          SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _requestOtp,
                icon: Icon(Icons.send_outlined, size: 18),
                label: const Text("Request OTP"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade600, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          
          if (_isOtpSent) ...[
            const SizedBox(height: 20),
            // OTP Field
            _buildTextField(
              controller: _otpController,
              label: "OTP",
              hint: "Enter the OTP",
              icon: Icons.lock_outline,
              keyboardType: TextInputType.number,
              maxLength: 6,
              focusNode: _otpFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: () {
                if (!_isOtpVerified) {
                  _verifyOtp();
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'OTP is required';
                }
                if (value.length != 6) {
                  return 'OTP must be 6 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Verify OTP Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isOtpVerified || _isLoading ? null : _verifyOtp,
                icon: Icon(Icons.verified_outlined, size: 18),
                label: Text(_isOtpVerified ? "OTP Verified" : "Verify OTP"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOtpVerified ? Colors.green : Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          
          if (_isOtpVerified) ...[
            const SizedBox(height: 24),
            // PIN Field
            _buildTextField(
              controller: _pinController,
              label: "Set PIN",
              hint: "Enter 4-digit PIN",
              icon: Icons.lock_outline,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: _obscurePin,
              focusNode: _pinFocusNode,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePin = !_obscurePin;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'PIN is required';
                }
                if (value.length != 4) {
                  return 'PIN must be 4 digits';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    VoidCallback? onFieldSubmitted,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLength: maxLength,
          obscureText: obscureText,
          onFieldSubmitted: onFieldSubmitted != null ? (_) => onFieldSubmitted() : null,
          onChanged: onChanged ?? (value) {
            if (_errorMessage != null) {
              setState(() {
                _errorMessage = null;
              });
            }
          },
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
            letterSpacing: obscureText ? 8 : 0,
          ),
          decoration: InputDecoration(
            counterText: "",
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              letterSpacing: obscureText ? 8 : 0,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          
          return Row(
            children: [
              // Left side - Image (Desktop only)
              if (isWideScreen)
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade700,
                          Colors.blue.shade900,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/register.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Right side - Form
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.grey.shade50,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: isWideScreen ? 48.0 : 24.0,
                        right: isWideScreen ? 48.0 : 24.0,
                        top: 32.0,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 32.0,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWideScreen ? 600 : double.infinity,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo
                            Hero(
                              tag: 'logo',
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/Kitokopaylogo.png',
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Title
                            Text(
                              "Self Registration",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            
                            // Progress Indicator
                            _buildProgressIndicator(),
                            const SizedBox(height: 8),
                            _buildStepLabels(),
                            const SizedBox(height: 32),
                            
                            // Step Content
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: _buildStepContent(),
                            ),
                            
                            // Error Message
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 24),
                            
                            // Step 0: White Card Container with Continue, "or" divider, and Navigation Buttons
                            if (_currentStep == 0) ...[
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Continue Button (Primary)
                                    SizedBox(
                                      height: 56,
                            child: ElevatedButton(
                                        onPressed: _isLoading ? null : _nextStep,
                              style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                        ).copyWith(
                                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(MaterialState.disabled)) {
                                                return Colors.grey.shade300;
                                              }
                                              return Colors.transparent;
                                            },
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Colors.blue.shade400,
                                                Colors.blue.shade600,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                              ),
                              child: _isLoading
                                              ? const Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(16.0),
                                                    child: SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                                    child: Text(
                                                      "Continue",
                                      style: TextStyle(
                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Divider with "or"
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.shade300,
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            "or",
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.shade300,
                                            thickness: 1,
                              ),
                            ),
                          ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Navigation Buttons
                                    Row(
                                      children: [
                                        // Activate Account Button
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const OtpPage(),
                                                ),
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              side: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1.5,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                            children: [
                                                Icon(
                                                  Icons.verified_user_outlined,
                                                  size: 18,
                                                  color: Colors.grey.shade700,
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    "Activate Account",
                                style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey.shade800,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Log In Button
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              side: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1.5,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.login_outlined,
                                                  size: 18,
                                                  color: Colors.grey.shade700,
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    "Log In",
                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey.shade800,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Steps 1-3: Back and Continue buttons only
                              Row(
                                children: [
                                  if (_currentStep > 0)
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _previousStep,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text("Back"),
                                      ),
                                    ),
                                  if (_currentStep > 0) const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _nextStep,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ).copyWith(
                                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(MaterialState.disabled)) {
                                                return Colors.grey.shade300;
                                              }
                                              return Colors.transparent;
                                            },
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Colors.blue.shade400,
                                                Colors.blue.shade600,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: _isLoading
                                              ? const Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(16.0),
                                                    child: SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                    child: Text(
                                                      _currentStep == _totalSteps - 1 ? "Submit" : "Continue",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                            ],
                        ],
                        ),
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
