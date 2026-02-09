import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cf/core/api/interceptors/retry_interceptor.dart';

class MockDio extends Mock implements Dio {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Response<dynamic>(requestOptions: RequestOptions(path: ''), statusCode: 200));
    registerFallbackValue(DioException(requestOptions: RequestOptions(path: '')));
  });

  group('RetryInterceptor', () {
    late RetryInterceptor interceptor;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      interceptor = RetryInterceptor(dio: mockDio, baseDelayMs: 1); // Small delay for tests
    });

    test('retries on 429 status code', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 429,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      // Mock successful retry
      when(() => mockDio.fetch<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 200,
        ),
      );

      await interceptor.onError(error, handler);

      verify(() => mockDio.fetch<dynamic>(any())).called(1);
      verify(() => handler.resolve(any())).called(1);
    });

    test('retries on 500 status code', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      // Mock successful retry
      when(() => mockDio.fetch<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 200,
        ),
      );

      await interceptor.onError(error, handler);

      verify(() => mockDio.fetch<dynamic>(any())).called(1);
      verify(() => handler.resolve(any())).called(1);
    });

    test('retries on network error', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
        error: 'Connection timeout',
      );
      final handler = MockErrorInterceptorHandler();

      // Mock successful retry
      when(() => mockDio.fetch<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 200,
        ),
      );

      await interceptor.onError(error, handler);

      verify(() => mockDio.fetch<dynamic>(any())).called(1);
      verify(() => handler.resolve(any())).called(1);
    });
  });
}
