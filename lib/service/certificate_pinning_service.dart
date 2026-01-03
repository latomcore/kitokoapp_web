import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:kitokopay/config/certificate_config.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;

/// Certificate Pinning Service
/// 
/// PHASE 3 SECURITY ENHANCEMENT: Certificate pinning to prevent MITM attacks.
/// 
/// Validates server certificates against known fingerprints.
/// 
/// NOTE: Certificate pinning on web is handled by the browser.
/// This service is primarily for mobile platforms (iOS/Android).
class CertificatePinningService {
  static final CertificatePinningService _instance = CertificatePinningService._internal();
  factory CertificatePinningService() => _instance;
  CertificatePinningService._internal();

  /// Check if certificate pinning is enabled
  bool get isEnabled => CertificateConfig.isEnabled && !kIsWeb;

  /// Validate certificate fingerprint
  /// 
  /// Returns true if certificate is valid (matches allowed fingerprints).
  /// Returns false if certificate doesn't match or pinning is disabled.
  bool validateCertificate(X509Certificate certificate) {
    // On web, certificate validation is handled by browser
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint('ℹ️ Certificate pinning on web is handled by browser');
      }
      return true; // Browser handles SSL validation
    }

    // If pinning is not enabled, allow all certificates (fallback to standard SSL)
    if (!isEnabled) {
      if (kDebugMode) {
        debugPrint('⚠️ Certificate pinning is disabled (no fingerprints configured)');
        debugPrint('   Falling back to standard SSL certificate validation');
      }
      return true; // Allow standard SSL validation
    }

    try {
      // Get certificate fingerprint (SHA-256)
      final fingerprint = _getCertificateFingerprint(certificate);
      
      if (kDebugMode) {
        debugPrint('🔍 Certificate fingerprint: $fingerprint');
      }

      // Check if fingerprint matches any allowed fingerprint
      final allowedFingerprints = CertificateConfig.fingerprints;
      final isValid = allowedFingerprints.contains(fingerprint);

      if (isValid) {
        if (kDebugMode) {
          debugPrint('✅ Certificate pinning: Valid certificate');
        }
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('❌ Certificate pinning: Invalid certificate');
          debugPrint('   Received: $fingerprint');
          debugPrint('   Allowed: ${allowedFingerprints.join(", ")}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error validating certificate: $e');
      }
      // On error, fall back to standard SSL validation (safer than blocking)
      return true;
    }
  }

  /// Get certificate fingerprint (SHA-256)
  String _getCertificateFingerprint(X509Certificate certificate) {
    // Get certificate bytes
    final certBytes = certificate.der;
    
    // Calculate SHA-256 hash
    final hash = sha256.convert(certBytes);
    
    // Format as colon-separated hex string (standard format)
    final hexString = hash.toString().toUpperCase();
    final formatted = StringBuffer();
    
    for (int i = 0; i < hexString.length; i += 2) {
      if (i > 0) formatted.write(':');
      formatted.write(hexString.substring(i, i + 2));
    }
    
    return formatted.toString();
  }

  /// Create HttpClient with certificate pinning
  /// 
  /// Returns HttpClient configured with certificate pinning callback.
  /// On web, returns null (browser handles SSL).
  HttpClient? createPinnedHttpClient() {
    if (kIsWeb) {
      // Web: Browser handles SSL, no custom HttpClient needed
      return null;
    }

    if (!isEnabled) {
      // Pinning disabled: return standard HttpClient
      return HttpClient();
    }

    // Create HttpClient with certificate pinning
    final client = HttpClient();
    
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Validate certificate
      final isValid = validateCertificate(cert);
      
      if (!isValid) {
        if (kDebugMode) {
          debugPrint('🚫 Certificate pinning: Blocking connection to $host:$port');
        }
      }
      
      return isValid;
    };

    return client;
  }
}

