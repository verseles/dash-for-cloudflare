import 'package:dio/dio.dart';

/// Interceptor that adds Bearer token authorization to all requests.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getToken});

  final String Function() getToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getToken();
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }
}
