# Phase 3 Feature Implementation Details

## 📋 Detailed Implementation Plans

This document provides detailed implementation steps for each Phase 3 security feature.

---

## 🔐 1. Certificate Pinning

### Overview
Prevent MITM attacks by pinning server certificates.

### Implementation Steps

#### Step 1: Add Package
**File:** `pubspec.yaml`
```yaml
dependencies:
  certificate_pinning: ^2.0.0
```

#### Step 2: Create Certificate Config
**New File:** `lib/config/certificate_config.dart`
```dart
class CertificateConfig {
  // Production certificate fingerprint
  static const String productionFingerprint = 'SHA256:...';
  
  // Development certificate fingerprint (if different)
  static const String developmentFingerprint = 'SHA256:...';
  
  // Get fingerprint based on environment
  static String get fingerprint {
    const isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
    return isProduction ? productionFingerprint : developmentFingerprint;
  }
}
```

#### Step 3: Create Certificate Pinning Service
**New File:** `lib/service/certificate_pinning_service.dart`
```dart
import 'package:certificate_pinning/certificate_pinning.dart';
import 'package:kitokopay/config/certificate_config.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

class CertificatePinningService {
  static Future<bool> validateCertificate(String hostname) async {
    try {
      final result = await CertificatePinning.check(
        serverURL: hostname,
        headerHttp: Map<String, String>(),
        sha: CertificateConfig.fingerprint,
        timeout: 50,
      );
      
      if (kDebugMode) {
        debugPrint('Certificate validation: ${result ? "✅ Valid" : "❌ Invalid"}');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Certificate validation error: $e');
      }
      // Fallback: Allow connection if validation fails (for development)
      return true; // Change to false in production
    }
  }
}
```

#### Step 4: Integrate with API Client
**File:** `lib/service/api_client.dart`
- Add certificate validation before requests
- Handle certificate errors gracefully

#### Step 5: Get Certificate Fingerprint
```bash
# Get certificate fingerprint from server
openssl s_client -connect kitokoapp.com:443 -showcerts | openssl x509 -fingerprint -sha256 -noout
```

### Rollback
```bash
rm lib/service/certificate_pinning_service.dart
rm lib/config/certificate_config.dart
git checkout phase2-baseline -- lib/service/api_client.dart pubspec.yaml
flutter pub get
```

---

## ⏰ 2. Token Expiration & Refresh

### Overview
Implement token expiration checking and automatic refresh.

### Implementation Steps

#### Step 1: Create Token Refresh Service
**New File:** `lib/service/token_refresh_service.dart`
```dart
import 'package:kitokopay/service/api_client.dart';
import 'package:kitokopay/service/token_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

class TokenRefreshService {
  /// Check if token is expired (if JWT, extract expiration)
  static bool isTokenExpired(String? token) {
    if (token == null) return true;
    
    // If token is JWT, extract expiration
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        // Decode JWT payload
        final payload = parts[1];
        // Add padding if needed
        final normalized = base64.normalize(payload);
        final decoded = utf8.decode(base64.decode(normalized));
        final json = jsonDecode(decoded);
        
        if (json['exp'] != null) {
          final expiration = DateTime.fromMillisecondsSinceEpoch(json['exp'] * 1000);
          return DateTime.now().isAfter(expiration);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Could not parse token expiration: $e');
      }
    }
    
    // Default: Assume token is valid if we can't parse it
    return false;
  }
  
  /// Refresh token if expired
  static Future<String?> refreshToken() async {
    // Implement token refresh logic
    // This depends on your API's refresh endpoint
    return null;
  }
}
```

#### Step 2: Update Token Storage
**File:** `lib/service/token_storage.dart`
- Add expiration checking in `getToken()`
- Add refresh logic

#### Step 3: Update API Client
**File:** `lib/service/api_client.dart`
- Check token expiration before requests
- Refresh token if expired
- Handle refresh errors

### Rollback
```bash
rm lib/service/token_refresh_service.dart
git checkout phase2-baseline -- lib/service/token_storage.dart lib/service/api_client.dart
```

---

## 🚦 3. Rate Limiting

### Overview
Prevent brute force attacks by limiting API call frequency.

### Implementation Steps

#### Step 1: Create Rate Limiter
**New File:** `lib/service/rate_limiter.dart`
```dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

class RateLimiter {
  final Map<String, List<DateTime>> _requests = {};
  final int maxRequests;
  final Duration timeWindow;
  
  RateLimiter({
    this.maxRequests = 5,
    this.timeWindow = const Duration(minutes: 1),
  });
  
  /// Check if request is allowed
  bool isAllowed(String endpoint) {
    final now = DateTime.now();
    final requests = _requests[endpoint] ?? [];
    
    // Remove old requests outside time window
    requests.removeWhere((time) => now.difference(time) > timeWindow);
    
    if (requests.length >= maxRequests) {
      if (kDebugMode) {
        debugPrint('⚠️ Rate limit exceeded for $endpoint');
      }
      return false;
    }
    
    // Add current request
    requests.add(now);
    _requests[endpoint] = requests;
    
    return true;
  }
  
  /// Reset rate limiter for endpoint
  void reset(String endpoint) {
    _requests.remove(endpoint);
  }
}
```

#### Step 2: Integrate with API Client
**File:** `lib/service/api_client.dart`
- Add rate limiting checks before requests
- Return rate limit error if exceeded

#### Step 3: Handle Rate Limit Errors
**File:** `lib/src/screens/auth/login.dart`
- Show user-friendly rate limit message
- Disable login button temporarily

### Rollback
```bash
rm lib/service/rate_limiter.dart
git checkout phase2-baseline -- lib/service/api_client.dart lib/src/screens/auth/login.dart
```

---

## ✍️ 4. Request Signing

### Overview
Sign API requests to prevent tampering.

### Implementation Steps

#### Step 1: Create Request Signer
**New File:** `lib/service/request_signer.dart`
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:kitokopay/config/app_config.dart';

class RequestSigner {
  /// Sign request with HMAC
  static String signRequest(Map<String, dynamic> request, String timestamp) {
    // Create signature payload
    final payload = jsonEncode(request) + timestamp;
    
    // Get signing key from secure storage
    final signingKey = AppConfig.getSigningKey(); // Implement this
    
    // Generate HMAC signature
    final key = utf8.encode(signingKey);
    final bytes = utf8.encode(payload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    
    return digest.toString();
  }
  
  /// Verify request signature
  static bool verifySignature(String signature, Map<String, dynamic> request, String timestamp) {
    final expectedSignature = signRequest(request, timestamp);
    return signature == expectedSignature;
  }
}
```

#### Step 2: Integrate with API Client
**File:** `lib/service/api_client.dart`
- Add signature to request headers
- Include timestamp in request

### Rollback
```bash
rm lib/service/request_signer.dart
git checkout phase2-baseline -- lib/service/api_client.dart
```

---

## 👆 5. Biometric Authentication (Mobile)

### Overview
Add Face ID / Touch ID / Fingerprint authentication.

### Implementation Steps

#### Step 1: Add Package
**File:** `pubspec.yaml`
```yaml
dependencies:
  local_auth: ^2.1.0
```

#### Step 2: Create Biometric Auth Service
**New File:** `lib/service/biometric_auth_service.dart`
```dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

class BiometricAuthService {
  static final LocalAuthentication _auth = LocalAuthentication();
  
  /// Check if biometrics are available
  static Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Biometric check failed: $e');
      }
      return false;
    }
  }
  
  /// Authenticate with biometrics
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Biometric authentication failed: $e');
      }
      return false;
    }
  }
}
```

#### Step 3: Add to Login Screen
**File:** `lib/src/screens/auth/login.dart`
- Add biometric login button
- Check if biometrics available
- Handle biometric authentication

### Rollback
```bash
rm lib/service/biometric_auth_service.dart
git checkout phase2-baseline -- lib/src/screens/auth/login.dart pubspec.yaml
flutter pub get
```

---

## 📊 Implementation Priority

1. **Token Expiration** - High value, low risk
2. **Rate Limiting** - High value, low risk
3. **Certificate Pinning** - High value, medium risk
4. **Request Signing** - Medium value, medium risk
5. **Biometric Auth** - Nice to have, low risk

---

## ✅ Testing Checklist

For each feature:
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing
- [ ] Error handling
- [ ] Rollback testing
- [ ] Performance testing
- [ ] Documentation

---

## 📚 Related Files

- `PHASE3_IMPLEMENTATION_PLAN.md` - Overall plan
- `PHASE3_ROLLBACK_GUIDE.md` - Rollback procedures
- `PHASE3_QUICK_START.md` - Quick start guide

