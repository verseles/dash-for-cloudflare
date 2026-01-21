import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cf/core/api/interceptors/retry_interceptor.dart';

class MockDio extends Mock implements Dio {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  group('RetryInterceptor', () {
    late RetryInterceptor interceptor;
    late MockDio mockDio;
    late MockErrorInterceptorHandler mockHandler;

    setUp(() {
      mockDio = MockDio();
      mockHandler = MockErrorInterceptorHandler();
      interceptor = RetryInterceptor(
        dio: mockDio,
        maxRetries: 2,
        baseDelayMs: 1, // Short delay for testing
      );

      registerFallbackValue(RequestOptions(path: ''));
    });

    test('retries on 429', () async {
      final options = RequestOptions(path: '/test');
      final err = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 429,
        ),
      );

      when(() => mockDio.fetch(any())).thenAnswer(
        (_) async => Response(requestOptions: options, statusCode: 200),
      );

      await interceptor.onError(err, mockHandler);

      verify(() => mockDio.fetch(any())).called(1);
      verify(() => mockHandler.resolve(any())).called(1);
    });

    test('retries on 500', () async {
      final options = RequestOptions(path: '/test');
      final err = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 500,
        ),
      );

      when(() => mockDio.fetch(any())).thenAnswer(
        (_) async => Response(requestOptions: options, statusCode: 200),
      );

      await interceptor.onError(err, mockHandler);

      verify(() => mockDio.fetch(any())).called(1);
      verify(() => mockHandler.resolve(any())).called(1);
    });

    test('retries on connection timeout', () async {
      final options = RequestOptions(path: '/test');
      final err = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );

      when(() => mockDio.fetch(any())).thenAnswer(
        (_) async => Response(requestOptions: options, statusCode: 200),
      );

      await interceptor.onError(err, mockHandler);

      verify(() => mockDio.fetch(any())).called(1);
      verify(() => mockHandler.resolve(any())).called(1);
    });
  });
}
