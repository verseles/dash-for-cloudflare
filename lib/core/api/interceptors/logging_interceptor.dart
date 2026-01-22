import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that logs requests and responses in debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '┌──────────────────────────────────────────────────────────────',
      );
      debugPrint('│ 📤 REQUEST: ${options.method} ${options.uri}');
      if (options.data != null) {
        debugPrint('│ 📦 Body: ${options.data}');
      }
      debugPrint(
        '└──────────────────────────────────────────────────────────────',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '┌──────────────────────────────────────────────────────────────',
      );
      debugPrint(
        '│ 📥 RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
      );
      debugPrint(
        '│ ⏱️ Time: ${response.requestOptions.extra['startTime'] != null ? '${DateTime.now().difference(response.requestOptions.extra['startTime'] as DateTime).inMilliseconds}ms' : 'N/A'}',
      );
      debugPrint(
        '└──────────────────────────────────────────────────────────────',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '┌──────────────────────────────────────────────────────────────',
      );
      debugPrint(
        '│ ❌ ERROR: ${err.response?.statusCode ?? 'N/A'} ${err.requestOptions.uri}',
      );
      debugPrint('│ 📝 Message: ${err.message}');
      debugPrint(
        '│ 🔑 Auth Header: ${err.requestOptions.headers['Authorization']?.toString().substring(0, 20) ?? 'none'}...',
      );
      if (err.response?.data != null) {
        debugPrint('│ 📦 Response: ${err.response?.data}');
      }
      debugPrint(
        '└──────────────────────────────────────────────────────────────',
      );
    }
    handler.next(err);
  }
}
