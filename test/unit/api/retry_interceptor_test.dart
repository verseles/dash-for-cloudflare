import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cf/core/api/interceptors/retry_interceptor.dart';

class MockDio extends Mock implements Dio {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Response<dynamic>(
        requestOptions: RequestOptions(path: ''), statusCode: 200));
    registerFallbackValue(DioException(requestOptions: RequestOptions(path: '')));
  });

  group('RetryInterceptor', () {
    late RetryInterceptor interceptor;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      interceptor = RetryInterceptor(dio: mockDio, baseDelayMs: 1);
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

    test('retries on 503 status code', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 503,
        ),
      );
      final handler = MockErrorInterceptorHandler();

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

    test('retries on connectionTimeout', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      final handler = MockErrorInterceptorHandler();

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

    test('retries on sendTimeout', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );
      final handler = MockErrorInterceptorHandler();

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

    test('retries on receiveTimeout', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );
      final handler = MockErrorInterceptorHandler();

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

    test('retries on connectionError', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      final handler = MockErrorInterceptorHandler();

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

    test('does not retry on 400 (bad request)', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      await interceptor.onError(error, handler);

      verifyNever(() => mockDio.fetch<dynamic>(any()));
      verify(() => handler.next(any())).called(1);
    });

    test('does not retry on 401 (unauthorized)', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      await interceptor.onError(error, handler);

      verifyNever(() => mockDio.fetch<dynamic>(any()));
      verify(() => handler.next(any())).called(1);
    });

    test('does not retry on 403 (forbidden)', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      await interceptor.onError(error, handler);

      verifyNever(() => mockDio.fetch<dynamic>(any()));
      verify(() => handler.next(any())).called(1);
    });

    test('does not retry on 404 (not found)', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      await interceptor.onError(error, handler);

      verifyNever(() => mockDio.fetch<dynamic>(any()));
      verify(() => handler.next(any())).called(1);
    });

    test('does not retry on badResponse type with 4xx', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 422,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      await interceptor.onError(error, handler);

      verifyNever(() => mockDio.fetch<dynamic>(any()));
      verify(() => handler.next(any())).called(1);
    });

    test('does not retry on cancel', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );
      final handler = MockErrorInterceptorHandler();

      await interceptor.onError(error, handler);

      verifyNever(() => mockDio.fetch<dynamic>(any()));
      verify(() => handler.next(any())).called(1);
    });

    test('stops retrying after maxRetries exhausted', () async {
      final interceptor2 =
          RetryInterceptor(dio: mockDio, baseDelayMs: 1, maxRetries: 2);
      // Simulate already at max retries
      final opts = RequestOptions(path: '/test');
      opts.extra['retryCount'] = 2;

      final error = DioException(
        requestOptions: opts,
        response: Response(requestOptions: opts, statusCode: 500),
      );
      final handler = MockErrorInterceptorHandler();

      await interceptor2.onError(error, handler);

      verifyNever(() => mockDio.fetch<dynamic>(any()));
      verify(() => handler.next(any())).called(1);
    });

    test('propagates DioException when retry fails with DioException',
        () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      when(() => mockDio.fetch<dynamic>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        ),
      );

      await interceptor.onError(error, handler);

      verify(() => mockDio.fetch<dynamic>(any())).called(1);
      verify(() => handler.next(any())).called(1);
      verifyNever(() => handler.resolve(any()));
    });

    test('wraps non-DioException in DioException when retry fails', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      when(() => mockDio.fetch<dynamic>(any()))
          .thenThrow(Exception('unexpected'));

      await interceptor.onError(error, handler);

      verify(() => mockDio.fetch<dynamic>(any())).called(1);
      verify(() => handler.next(any())).called(1);
      verifyNever(() => handler.resolve(any()));
    });

    test('increments retryCount in request options', () async {
      RequestOptions? capturedOptions;
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      final handler = MockErrorInterceptorHandler();

      when(() => mockDio.fetch<dynamic>(any())).thenAnswer((invocation) async {
        capturedOptions =
            invocation.positionalArguments[0] as RequestOptions;
        return Response(
          requestOptions: capturedOptions!,
          statusCode: 200,
        );
      });

      await interceptor.onError(error, handler);

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.extra['retryCount'], equals(1));
    });
  });
}
