import 'package:dio/dio.dart';

/// Interceptor that monitors Cloudflare rate limit headers.
/// Headers: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
class RateLimitInterceptor extends Interceptor {
  int? _limit;
  int? _remaining;
  DateTime? _resetTime;

  /// Current rate limit
  int? get limit => _limit;

  /// Remaining requests in current window
  int? get remaining => _remaining;

  /// When the rate limit resets
  DateTime? get resetTime => _resetTime;

  /// Whether we're close to the rate limit (< 10% remaining)
  bool get isNearLimit {
    if (_limit == null || _remaining == null) return false;
    return _remaining! < (_limit! * 0.1);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _extractRateLimitHeaders(response.headers);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _extractRateLimitHeaders(err.response!.headers);
    }
    handler.next(err);
  }

  void _extractRateLimitHeaders(Headers headers) {
    final limitHeader = headers.value('X-RateLimit-Limit');
    final remainingHeader = headers.value('X-RateLimit-Remaining');
    final resetHeader = headers.value('X-RateLimit-Reset');

    if (limitHeader != null) {
      _limit = int.tryParse(limitHeader);
    }
    if (remainingHeader != null) {
      _remaining = int.tryParse(remainingHeader);
    }
    if (resetHeader != null) {
      final resetTimestamp = int.tryParse(resetHeader);
      if (resetTimestamp != null) {
        _resetTime = DateTime.fromMillisecondsSinceEpoch(resetTimestamp * 1000);
      }
    }
  }
}
