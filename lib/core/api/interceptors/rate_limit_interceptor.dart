import 'package:dio/dio.dart';

import '../../logging/log_service.dart';

/// Interceptor that monitors Cloudflare rate limit headers.
/// Headers: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
class RateLimitInterceptor extends Interceptor {
  int? _limit;
  int? _remaining;
  DateTime? _resetTime;
  bool _wasNearLimit = false;

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

    // Log API response
    final duration = response.requestOptions.extra['startTime'] as DateTime?;
    final durationMs = duration != null
        ? DateTime.now().difference(duration).inMilliseconds
        : null;

    log.apiResponse(
      response.requestOptions.method,
      response.requestOptions.path,
      response.statusCode ?? 0,
      durationMs: durationMs,
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _extractRateLimitHeaders(err.response!.headers);

      log.apiError(
        err.requestOptions.method,
        err.requestOptions.path,
        statusCode: err.response?.statusCode,
        error: err.message,
      );
    } else {
      log.apiError(
        err.requestOptions.method,
        err.requestOptions.path,
        error: err.type.name,
      );
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

    // Log warning if approaching rate limit
    if (isNearLimit && !_wasNearLimit) {
      log.warning(
        'Approaching rate limit',
        details: 'Remaining: $_remaining/$_limit (resets: $_resetTime)',
      );
      _wasNearLimit = true;
    } else if (!isNearLimit) {
      _wasNearLimit = false;
    }
  }
}
