import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cf/core/api/interceptors/rate_limit_interceptor.dart';

void main() {
  group('RateLimitInterceptor', () {
    late RateLimitInterceptor interceptor;

    setUp(() {
      interceptor = RateLimitInterceptor();
    });

    group('initial state', () {
      test('limit is null initially', () {
        expect(interceptor.limit, isNull);
      });

      test('remaining is null initially', () {
        expect(interceptor.remaining, isNull);
      });

      test('resetTime is null initially', () {
        expect(interceptor.resetTime, isNull);
      });

      test('isNearLimit is false initially', () {
        expect(interceptor.isNearLimit, false);
      });
    });

    group('onResponse', () {
      test('extracts rate limit headers from response', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/zones'),
          statusCode: 200,
          headers: Headers.fromMap({
            'X-RateLimit-Limit': ['1200'],
            'X-RateLimit-Remaining': ['1150'],
            'X-RateLimit-Reset': ['1704067200'], // 2024-01-01 00:00:00 UTC
          }),
        );
        final handler = ResponseInterceptorHandler();

        interceptor.onResponse(response, handler);

        expect(interceptor.limit, 1200);
        expect(interceptor.remaining, 1150);
        expect(interceptor.resetTime, isNotNull);
        expect(handler.isCompleted, true);
      });

      test('handles missing headers gracefully', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/zones'),
          statusCode: 200,
        );
        final handler = ResponseInterceptorHandler();

        interceptor.onResponse(response, handler);

        expect(interceptor.limit, isNull);
        expect(interceptor.remaining, isNull);
        expect(handler.isCompleted, true);
      });
    });

    group('onError', () {
      test('extracts rate limit headers from error response', () async {
        final response = Response(
          requestOptions: RequestOptions(path: '/zones'),
          statusCode: 429,
          headers: Headers.fromMap({
            'X-RateLimit-Limit': ['1200'],
            'X-RateLimit-Remaining': ['0'],
            'X-RateLimit-Reset': ['1704067200'],
          }),
        );
        final error = DioException(
          requestOptions: RequestOptions(path: '/zones'),
          response: response,
        );
        final handler = ErrorInterceptorHandler();

        interceptor.onError(error, handler);

        expect(interceptor.limit, 1200);
        expect(interceptor.remaining, 0);
        expect(handler.isCompleted, true);
      });

      test('handles error without response', () async {
        final error = DioException(
          requestOptions: RequestOptions(path: '/zones'),
          type: DioExceptionType.connectionTimeout,
        );
        final handler = ErrorInterceptorHandler();

        // Should not throw
        interceptor.onError(error, handler);
        expect(handler.isCompleted, true);
      });
    });

    group('isNearLimit', () {
      test('returns true when remaining is less than 10% of limit', () {
        // Simulate receiving response with low remaining
        final response = Response(
          requestOptions: RequestOptions(path: '/zones'),
          statusCode: 200,
          headers: Headers.fromMap({
            'X-RateLimit-Limit': ['1000'],
            'X-RateLimit-Remaining': ['50'], // 5% remaining
          }),
        );
        final handler = ResponseInterceptorHandler();

        interceptor.onResponse(response, handler);

        expect(interceptor.isNearLimit, true);
      });

      test('returns false when remaining is more than 10% of limit', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/zones'),
          statusCode: 200,
          headers: Headers.fromMap({
            'X-RateLimit-Limit': ['1000'],
            'X-RateLimit-Remaining': ['500'], // 50% remaining
          }),
        );
        final handler = ResponseInterceptorHandler();

        interceptor.onResponse(response, handler);

        expect(interceptor.isNearLimit, false);
      });

      test('returns false when at exactly 10%', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/zones'),
          statusCode: 200,
          headers: Headers.fromMap({
            'X-RateLimit-Limit': ['1000'],
            'X-RateLimit-Remaining': ['100'], // exactly 10%
          }),
        );
        final handler = ResponseInterceptorHandler();

        interceptor.onResponse(response, handler);

        // 100 is not < 100 (10% of 1000), so should be false
        expect(interceptor.isNearLimit, false);
      });
    });
  });
}
