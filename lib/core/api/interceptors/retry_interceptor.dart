import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';

/// Interceptor that retries failed requests with exponential backoff.
/// Handles rate limiting (429) and server errors (5xx).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelayMs = 1000,
  });

  final Dio dio;
  final int maxRetries;
  final int baseDelayMs;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final shouldRetry = _shouldRetry(statusCode);
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (shouldRetry && retryCount < maxRetries) {
      final delay = _calculateDelay(retryCount, statusCode, err.response);
      await Future.delayed(Duration(milliseconds: delay));

      try {
        final options = err.requestOptions;
        options.extra['retryCount'] = retryCount + 1;

        final response = await dio.fetch(options);
        handler.resolve(response);
        return;
      } catch (e) {
        // Let it fall through to handler.next
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(int? statusCode) {
    if (statusCode == null) return false;
    // Retry on rate limit (429) or server errors (5xx)
    return statusCode == 429 || (statusCode >= 500 && statusCode < 600);
  }

  int _calculateDelay(int retryCount, int? statusCode, Response? response) {
    // Check for Retry-After header
    if (statusCode == 429 && response != null) {
      final retryAfter = response.headers.value('Retry-After');
      if (retryAfter != null) {
        final seconds = int.tryParse(retryAfter);
        if (seconds != null) {
          return seconds * 1000;
        }
      }
    }

    // Exponential backoff with jitter
    final exponentialDelay = baseDelayMs * pow(2, retryCount).toInt();
    final jitter = Random().nextInt(baseDelayMs);
    return exponentialDelay + jitter;
  }
}
