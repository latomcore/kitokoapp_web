import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// Rate Limiter Service
/// 
/// PHASE 3 SECURITY ENHANCEMENT: Prevents API abuse by limiting request frequency.
/// 
/// Features:
/// - Per-endpoint rate limiting
/// - Sliding window algorithm
/// - Configurable limits
/// - User-friendly error messages
class RateLimiter {
  static final RateLimiter _instance = RateLimiter._internal();
  factory RateLimiter() => _instance;
  RateLimiter._internal();

  // Store request timestamps per endpoint
  final Map<String, List<DateTime>> _requestHistory = {};
  
  // Rate limit configuration per endpoint
  final Map<String, RateLimitConfig> _endpointLimits = {
    // Auth endpoints - stricter limits
    'auth': RateLimitConfig(maxRequests: 5, windowSeconds: 60), // 5 requests per minute
    'login': RateLimitConfig(maxRequests: 3, windowSeconds: 60), // 3 login attempts per minute
    'activate': RateLimitConfig(maxRequests: 3, windowSeconds: 60), // 3 activation attempts per minute
    
    // Core API endpoints - moderate limits
    'core': RateLimitConfig(maxRequests: 30, windowSeconds: 60), // 30 requests per minute
    'load': RateLimitConfig(maxRequests: 10, windowSeconds: 60), // 10 requests per minute
    
    // Default limit for unknown endpoints
    'default': RateLimitConfig(maxRequests: 20, windowSeconds: 60), // 20 requests per minute
  };

  /// Check if a request is allowed for the given endpoint
  /// 
  /// Returns true if request is allowed, false if rate limit exceeded.
  /// Automatically cleans up old request timestamps.
  bool checkRateLimit(String endpoint) {
    // Get endpoint key (extract base path)
    final endpointKey = _getEndpointKey(endpoint);
    final config = _endpointLimits[endpointKey] ?? _endpointLimits['default']!;
    
    // Get or create request history for this endpoint
    final history = _requestHistory.putIfAbsent(endpointKey, () => []);
    
    // Clean up old requests outside the window
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(seconds: config.windowSeconds));
    history.removeWhere((timestamp) => timestamp.isBefore(windowStart));
    
    // Check if limit exceeded
    if (history.length >= config.maxRequests) {
      if (kDebugMode) {
        final oldestRequest = history.first;
        final waitTime = config.windowSeconds - now.difference(oldestRequest).inSeconds;
        debugPrint('🚫 Rate limit exceeded for $endpointKey');
        debugPrint('   Limit: ${config.maxRequests} requests per ${config.windowSeconds}s');
        debugPrint('   Current: ${history.length} requests');
        debugPrint('   Wait: ${waitTime}s before next request');
      }
      return false;
    }
    
    // Add current request timestamp
    history.add(now);
    
    if (kDebugMode && history.length > config.maxRequests * 0.8) {
      debugPrint('⚠️ Rate limit warning for $endpointKey: ${history.length}/${config.maxRequests} requests');
    }
    
    return true;
  }

  /// Get remaining requests for an endpoint
  int getRemainingRequests(String endpoint) {
    final endpointKey = _getEndpointKey(endpoint);
    final config = _endpointLimits[endpointKey] ?? _endpointLimits['default']!;
    final history = _requestHistory[endpointKey] ?? [];
    
    // Clean up old requests
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(seconds: config.windowSeconds));
    history.removeWhere((timestamp) => timestamp.isBefore(windowStart));
    
    return config.maxRequests - history.length;
  }

  /// Get wait time in seconds before next request is allowed
  int getWaitTime(String endpoint) {
    final endpointKey = _getEndpointKey(endpoint);
    final history = _requestHistory[endpointKey];
    
    if (history == null || history.isEmpty) {
      return 0;
    }
    
    final config = _endpointLimits[endpointKey] ?? _endpointLimits['default']!;
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(seconds: config.windowSeconds));
    
    // Find oldest request in window
    final requestsInWindow = history.where((t) => t.isAfter(windowStart)).toList();
    if (requestsInWindow.isEmpty) {
      return 0;
    }
    
    final oldestRequest = requestsInWindow.reduce((a, b) => a.isBefore(b) ? a : b);
    final waitTime = config.windowSeconds - now.difference(oldestRequest).inSeconds;
    
    return waitTime > 0 ? waitTime : 0;
  }

  /// Reset rate limit for an endpoint (useful for testing or manual reset)
  void resetRateLimit(String endpoint) {
    final endpointKey = _getEndpointKey(endpoint);
    _requestHistory.remove(endpointKey);
    
    if (kDebugMode) {
      debugPrint('🔄 Rate limit reset for $endpointKey');
    }
  }

  /// Reset all rate limits
  void resetAll() {
    _requestHistory.clear();
    
    if (kDebugMode) {
      debugPrint('🔄 All rate limits reset');
    }
  }

  /// Extract endpoint key from full URL
  String _getEndpointKey(String endpoint) {
    // Extract key from URL path
    if (endpoint.contains('/auth') || endpoint.contains('auth')) {
      return 'auth';
    } else if (endpoint.contains('/login') || endpoint.contains('login')) {
      return 'login';
    } else if (endpoint.contains('/activate') || endpoint.contains('activate')) {
      return 'activate';
    } else if (endpoint.contains('/load') || endpoint.contains('load')) {
      return 'load';
    } else if (endpoint.contains('/core') || endpoint.contains('core')) {
      return 'core';
    }
    return 'default';
  }
}

/// Rate limit configuration
class RateLimitConfig {
  final int maxRequests;
  final int windowSeconds;

  RateLimitConfig({
    required this.maxRequests,
    required this.windowSeconds,
  });
}

