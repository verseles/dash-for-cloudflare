import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cf/core/api/interceptors/auth_interceptor.dart';

void main() {
  group('AuthInterceptor', () {
    late AuthInterceptor interceptor;
    late String currentToken;

    setUp(() {
      currentToken = 'test_api_token_1234567890abcdefghijklmnop';
      interceptor = AuthInterceptor(getToken: () => currentToken);
    });

    test('adds Authorization header when token is not empty', () async {
      final options = RequestOptions(path: '/zones');
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(
        options.headers['Authorization'],
        'Bearer test_api_token_1234567890abcdefghijklmnop',
      );
      expect(handler.isCompleted, true);
    });

    test('does not add Authorization header when token is empty', () async {
      currentToken = '';
      final options = RequestOptions(path: '/zones');
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], isNull);
      expect(handler.isCompleted, true);
    });

    test('always adds Content-Type header', () async {
      final options = RequestOptions(path: '/zones');
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers['Content-Type'], 'application/json');
    });

    test('updates token dynamically', () async {
      final options1 = RequestOptions(path: '/zones');
      final handler1 = RequestInterceptorHandler();

      interceptor.onRequest(options1, handler1);
      expect(
        options1.headers['Authorization'],
        'Bearer test_api_token_1234567890abcdefghijklmnop',
      );

      // Change token
      currentToken = 'new_token_abcdefghij1234567890abcdefghijk';

      final options2 = RequestOptions(path: '/zones');
      final handler2 = RequestInterceptorHandler();

      interceptor.onRequest(options2, handler2);
      expect(
        options2.headers['Authorization'],
        'Bearer new_token_abcdefghij1234567890abcdefghijk',
      );
    });
  });
}
