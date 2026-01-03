/// Certificate Configuration
/// 
/// PHASE 3 SECURITY ENHANCEMENT: Certificate pinning configuration.
/// 
/// Stores allowed certificate fingerprints for certificate pinning.
/// 
/// IMPORTANT: Update this when server certificate changes!
class CertificateConfig {
  // Certificate fingerprints (SHA-256)
  // These should match your server's SSL certificate
  // To get fingerprint: openssl s_client -connect kitokoapp.com:443 -servername kitokoapp.com < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
  static const List<String> allowedFingerprints = [
    // Certificate fingerprint for kitokoapp.com (SHA-256)
    // Obtained: 2026-01-02
    // To update: Run PowerShell command or use OpenSSL to get new fingerprint
    '35:A8:14:2C:B6:3E:D5:0A:22:A1:CF:E2:58:65:37:C0:81:FB:D1:1B:93:3A:81:E6:49:0C:AA:C9:14:48:1C:91',
  ];

  // Hostname for certificate validation
  static const String hostname = 'kitokoapp.com';

  // Port for certificate validation
  static const int port = 443;

  /// Check if certificate pinning is enabled
  static bool get isEnabled => allowedFingerprints.isNotEmpty;

  /// Get allowed fingerprints
  static List<String> get fingerprints => List.unmodifiable(allowedFingerprints);
}

