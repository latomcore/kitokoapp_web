import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  Country? _selectedCountry;
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Country Code Dropdown and Flag
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true, // Show country phone code
              onSelect: (Country country) {
                setState(() {
                  _selectedCountry = country;
                });
                // Automatically update the phone number with country code
                String currentPhone = _phoneController.text;
                if (currentPhone.isNotEmpty &&
                    !currentPhone.startsWith("+${country.phoneCode}")) {
                  _phoneController.text = "+${country.phoneCode}$currentPhone";
                }
              },
              countryListTheme: CountryListThemeData(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
                inputDecoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Start typing to search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0xFF8C98A8).withOpacity(0.2),
                    ),
                  ),
                ),
                searchTextStyle: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _selectedCountry != null
                    ? Row(
                        children: [
                          Text(_selectedCountry!.flagEmoji), // Flag
                          Text("+${_selectedCountry!.phoneCode}"), // Phone Code
                        ],
                      )
                    : const Icon(Icons.flag),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Phone Number Input Field
        Expanded(
          child: TextField(
            controller: _phoneController,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              // Keep country code intact when phone number is edited
              if (_selectedCountry != null &&
                  !value.startsWith("+${_selectedCountry!.phoneCode}")) {
                _phoneController.text = "+${_selectedCountry!.phoneCode}$value";
                _phoneController.selection = TextSelection.collapsed(
                    offset: _phoneController.text.length);
              }
            },
          ),
        ),
      ],
    );
  }
}
