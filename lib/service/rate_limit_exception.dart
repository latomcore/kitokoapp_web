/// Rate Limit Exception
/// 
/// Thrown when rate limit is exceeded.
class RateLimitException implements Exception {
  final String message;
  final int waitTime; // Seconds to wait before retry

  RateLimitException(this.message, {required this.waitTime});

  @override
  String toString() => message;
}

