import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/api_config.dart';
import '../api/client/cloudflare_api.dart';
import '../api/client/cloudflare_graphql.dart';
import '../api/interceptors/auth_interceptor.dart';
import '../api/interceptors/retry_interceptor.dart';
import '../api/interceptors/rate_limit_interceptor.dart';
import '../api/interceptors/logging_interceptor.dart';

part 'api_providers.g.dart';

/// Provider for API token - must be overridden by SettingsNotifier
@riverpod
String apiToken(Ref ref) {
  // This will be overridden when settings are loaded
  return '';
}

/// Provider for rate limit interceptor (singleton for monitoring)
@riverpod
RateLimitInterceptor rateLimitInterceptor(Ref ref) {
  return RateLimitInterceptor();
}

/// Provider for Dio HTTP client with all interceptors
@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  // Add interceptors in order
  dio.interceptors.addAll([
    AuthInterceptor(getToken: () => ref.read(apiTokenProvider)),
    ref.read(rateLimitInterceptorProvider),
    RetryInterceptor(dio: dio),
    LoggingInterceptor(),
  ]);

  return dio;
}

/// Provider for Cloudflare REST API client
@riverpod
CloudflareApi cloudflareApi(Ref ref) {
  return CloudflareApi(ref.watch(dioProvider));
}

/// Provider for Cloudflare GraphQL client
@riverpod
CloudflareGraphQL cloudflareGraphQL(Ref ref) {
  return CloudflareGraphQL(ref.watch(dioProvider));
}
