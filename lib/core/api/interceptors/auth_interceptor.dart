import 'package:dio/dio.dart';

import '../../logging/log_service.dart';

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

    // Log the request
    log.apiRequest(
      options.method,
      options.path,
      headers: {'hasAuth': token.isNotEmpty.toString()},
    );

    handler.next(options);
  }
}
