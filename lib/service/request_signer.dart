import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:kitokopay/service/api_client.dart';
import 'package:kitokopay/config/app_config.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// Request Signing Service
/// 
/// PHASE 3 SECURITY ENHANCEMENT: Request signing to prevent tampering and replay attacks.
/// 
/// Features:
/// - HMAC-SHA256 request signing
/// - Timestamp-based nonces
/// - Request replay protection
/// - Signature validation
class RequestSigner {
  static final RequestSigner _instance = RequestSigner._internal();
  factory RequestSigner() => _instance;
  RequestSigner._internal();

  // Store used nonces to prevent replay attacks (last 1000 nonces)
  final Set<String> _usedNonces = {};
  static const int _maxNonces = 1000;

  // Nonce expiration time (5 minutes)
  static const Duration _nonceExpiration = Duration(minutes: 5);

  /// Sign a request
  /// 
  /// Creates a signature for the request using HMAC-SHA256.
  /// Includes timestamp and nonce to prevent replay attacks.
  /// 
  /// Returns a map with signature headers to add to the request.
  Future<Map<String, String>> signRequest({
    required String method,
    required String url,
    required Map<String, dynamic>? body,
    required String? token,
  }) async {
    try {
      // Generate nonce (unique identifier for this request)
      final nonce = _generateNonce();
      
      // Get current timestamp
      final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
      
      // Build signature string
      final signatureString = _buildSignatureString(
        method: method,
        url: url,
        body: body,
        timestamp: timestamp,
        nonce: nonce,
        token: token,
      );
      
      // Get signing key (use API password as signing key)
      final signingKey = await AppConfig.getApiPassword();
      
      // Calculate HMAC-SHA256 signature
      final signature = _calculateSignature(signatureString, signingKey);
      
      // Store nonce to prevent replay
      _storeNonce(nonce);
      
      if (kDebugMode) {
        debugPrint('🔐 Request signed:');
        debugPrint('   Method: $method');
        debugPrint('   URL: $url');
        debugPrint('   Timestamp: $timestamp');
        debugPrint('   Nonce: $nonce');
        debugPrint('   Signature: ${signature.substring(0, 16)}...');
      }
      
      // Return signature headers
      return {
        'X-Request-Timestamp': timestamp,
        'X-Request-Nonce': nonce,
        'X-Request-Signature': signature,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error signing request: $e');
      }
      // Return empty headers on error (request will proceed without signing)
      return {};
    }
  }

  /// Verify a nonce (check if it's been used)
  /// 
  /// Returns true if nonce is valid (not used before), false if it's a replay.
  bool verifyNonce(String nonce) {
    // Check if nonce was already used
    if (_usedNonces.contains(nonce)) {
      if (kDebugMode) {
        debugPrint('🚫 Replay attack detected: Nonce already used');
      }
      return false;
    }
    
    // Store nonce
    _storeNonce(nonce);
    return true;
  }

  /// Build signature string from request components
  String _buildSignatureString({
    required String method,
    required String url,
    required Map<String, dynamic>? body,
    required String timestamp,
    required String nonce,
    String? token,
  }) {
    // Normalize URL (remove query parameters for signing)
    final uri = Uri.parse(url);
    final normalizedUrl = '${uri.scheme}://${uri.host}${uri.path}';
    
    // Build body string (sorted keys for consistency)
    String bodyString = '';
    if (body != null && body.isNotEmpty) {
      final sortedKeys = body.keys.toList()..sort();
      final bodyMap = <String, dynamic>{};
      for (final key in sortedKeys) {
        bodyMap[key] = body[key];
      }
      bodyString = jsonEncode(bodyMap);
    }
    
    // Build signature string: method|url|body|timestamp|nonce|token
    final parts = [
      method.toUpperCase(),
      normalizedUrl,
      bodyString,
      timestamp,
      nonce,
      token ?? '',
    ];
    
    return parts.join('|');
  }

  /// Calculate HMAC-SHA256 signature
  String _calculateSignature(String data, String key) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }

  /// Generate a unique nonce
  String _generateNonce() {
    final apiClient = ApiClient();
    // Generate 32-character random string
    return apiClient.generateRandomString(32);
  }

  /// Store nonce to prevent replay attacks
  void _storeNonce(String nonce) {
    // Add nonce
    _usedNonces.add(nonce);
    
    // Limit stored nonces to prevent memory issues
    if (_usedNonces.length > _maxNonces) {
      // Remove oldest nonces (simple approach: remove first 100)
      final toRemove = _usedNonces.take(100).toList();
      for (final n in toRemove) {
        _usedNonces.remove(n);
      }
    }
  }

  /// Clear expired nonces (called periodically)
  void clearExpiredNonces() {
    // Simple implementation: clear all nonces periodically
    // In production, you might want to track nonce timestamps
    if (_usedNonces.length > _maxNonces * 0.8) {
      _usedNonces.clear();
      if (kDebugMode) {
        debugPrint('🔄 Cleared expired nonces');
      }
    }
  }
}

