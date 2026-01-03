import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kitokopay/config/app_config.dart';
import 'package:kitokopay/service/secure_storage_service.dart';
import 'package:kitokopay/service/rate_limiter.dart'; // PHASE 3: Rate limiting
import 'package:kitokopay/service/rate_limit_exception.dart'; // PHASE 3: Rate limit exception
import 'package:flutter/foundation.dart';

/// Public Key Service
/// 
/// Handles fetching and caching of PUBLIC_KEY from the server.
/// PUBLIC_KEY is fetched from /load endpoint and cached for 12 hours.
class PublicKeyService {
  static final PublicKeyService _instance = PublicKeyService._internal();
  factory PublicKeyService() => _instance;
  PublicKeyService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();

  /// Fetch PUBLIC_KEY from server
  /// 
  /// Makes a POST request to /load endpoint with Basic Auth
  /// and extracts PUBLIC_KEY from the response.
  Future<String?> fetchPublicKey() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Fetching PUBLIC_KEY from server...');
      }

      // Get API credentials from secure storage
      final username = await _secureStorage.getApiUsername();
      final password = await _secureStorage.getApiPassword();

      if (username == null || password == null) {
        if (kDebugMode) {
          debugPrint('❌ API credentials not found in secure storage');
        }
        return null;
      }

      // Create Basic Auth header
      final credentials = '$username:$password';
      final base64Credentials = base64Encode(utf8.encode(credentials));
      final basicAuth = 'Basic $base64Credentials';

      // PHASE 3: Check rate limit before making request
      final rateLimiter = RateLimiter();
      if (!rateLimiter.checkRateLimit(AppConfig.loadApiEndPoint)) {
        final waitTime = rateLimiter.getWaitTime(AppConfig.loadApiEndPoint);
        throw RateLimitException(
          'Too many requests to load endpoint. Please wait ${waitTime}s before trying again.',
          waitTime: waitTime,
        );
      }

      // Make request to /load endpoint
      final response = await http.post(
        Uri.parse(AppConfig.loadApiEndPoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: '', // Empty body as per API spec
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout while fetching PUBLIC_KEY');
        },
      );

      if (kDebugMode) {
        debugPrint('📊 /load endpoint response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        // Parse response to extract PUBLIC_KEY
        // Response format:
        // {
        //   "Status": "200",
        //   "Type": "object",
        //   "Data": {
        //     "hasUrl": "YES",
        //     "url": "...",
        //     "key": "PUBLIC_KEY_HERE"
        //   }
        // }
        final responseBody = response.body;
        
        if (kDebugMode) {
          debugPrint('📄 Response body length: ${responseBody.length}');
        }

        try {
          final jsonResponse = json.decode(responseBody) as Map<String, dynamic>;
          
          // Check Status field
          final status = jsonResponse['Status'] as String?;
          if (status != '200') {
            if (kDebugMode) {
              debugPrint('⚠️ API returned non-200 status: $status');
            }
            return null;
          }

          // Extract PUBLIC_KEY from Data.key
          final data = jsonResponse['Data'] as Map<String, dynamic>?;
          if (data == null) {
            if (kDebugMode) {
              debugPrint('⚠️ Response missing Data field');
            }
            return null;
          }

          final publicKey = data['key'] as String?;
          
          if (publicKey != null && publicKey.isNotEmpty) {
            // Store PUBLIC_KEY securely
            await _secureStorage.setPublicKey(publicKey);
            
            if (kDebugMode) {
              debugPrint('✅ PUBLIC_KEY fetched and stored successfully (${publicKey.length} chars)');
              // Also log the URL if present (for reference)
              final url = data['url'] as String?;
              if (url != null) {
                debugPrint('📋 API URL from response: $url');
              }
            }
            
            return publicKey;
          } else {
            if (kDebugMode) {
              debugPrint('⚠️ PUBLIC_KEY (key field) not found in Data object');
            }
            return null;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Failed to parse JSON response: $e');
            // Don't log full response body (may contain sensitive data)
            debugPrint('Response body: [Length: ${responseBody.length} chars]');
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ Failed to fetch PUBLIC_KEY. Status: ${response.statusCode}');
          // Don't log full response body (may contain sensitive data)
          debugPrint('Response: [Length: ${response.body.length} chars]');
        }
        return null;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching PUBLIC_KEY: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Get PUBLIC_KEY from cache or fetch if expired/missing
  /// 
  /// Returns cached PUBLIC_KEY if valid, otherwise fetches from server.
  Future<String?> getPublicKey({bool forceRefresh = false}) async {
    try {
      // Check if we need to refresh
      if (!forceRefresh) {
        final isExpired = await _secureStorage.isPublicKeyExpired();
        if (!isExpired) {
          final cachedKey = await _secureStorage.getPublicKey();
          if (cachedKey != null && cachedKey.isNotEmpty) {
            if (kDebugMode) {
              debugPrint('✅ Using cached PUBLIC_KEY');
            }
            return cachedKey;
          }
        } else {
          if (kDebugMode) {
            debugPrint('🔄 Cached PUBLIC_KEY expired, fetching new one...');
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('🔄 Force refreshing PUBLIC_KEY...');
        }
      }

      // Fetch new PUBLIC_KEY
      return await fetchPublicKey();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting PUBLIC_KEY: $e');
      }
      return null;
    }
  }

  /// Check if PUBLIC_KEY is available (cached or can be fetched)
  Future<bool> hasPublicKey() async {
    final key = await _secureStorage.getPublicKey();
    if (key != null && key.isNotEmpty) {
      final isExpired = await _secureStorage.isPublicKeyExpired();
      return !isExpired;
    }
    return false;
  }
}

