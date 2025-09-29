import 'dart:html'; // To use localStorage in the web
// For encoding and decoding data
// Import your token model

class TokenStorage {
  // Save the token to localStorage
  void setToken(String token) {
    window.localStorage['token'] = token;
  }

  // Retrieve the token from localStorage
  String? getToken() {
    return window.localStorage['token'];
  }

  // Clear the token from localStorage
  void clearToken() {
    window.localStorage.remove('token');
  }
}
