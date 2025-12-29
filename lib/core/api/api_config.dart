import 'package:flutter/foundation.dart' show kIsWeb;

/// API configuration with platform-aware URL selection.
/// Web platform requires CORS proxy, native platforms connect directly.
class ApiConfig {
  ApiConfig._();

  static const String _corsProxy = 'https://cors.verseles.com';
  static const String _cloudflareApiBase =
      'https://api.cloudflare.com/client/v4';
  static const String _graphqlEndpoint = '/graphql';

  /// Returns the appropriate base URL based on platform.
  /// - Web: Uses CORS proxy
  /// - Native (Android, iOS, Desktop): Direct connection
  static String get baseUrl {
    if (kIsWeb) {
      // Remove https:// and prepend proxy
      return '$_corsProxy/${_cloudflareApiBase.replaceFirst('https://', '')}';
    }
    return _cloudflareApiBase;
  }

  /// GraphQL endpoint URL
  static String get graphqlUrl => '$baseUrl$_graphqlEndpoint';

  /// Whether running on web platform
  static bool get isWeb => kIsWeb;

  /// Minimum token length for validation
  static const int minTokenLength = 40;

  /// Validates API token format
  static bool isValidToken(String? token) {
    return token != null && token.length >= minTokenLength;
  }
}
