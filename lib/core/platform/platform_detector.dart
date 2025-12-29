import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform detection utilities
class PlatformDetector {
  PlatformDetector._();

  /// Whether running on web platform
  static bool get isWeb => kIsWeb;

  /// Whether running on mobile (Android or iOS)
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Whether running on desktop (Linux, macOS, Windows)
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  }

  /// Whether running on Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Whether running on iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// Whether running on Linux
  static bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux;
  }

  /// Whether running on macOS
  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  /// Whether running on Windows
  static bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows;
  }

  /// Whether the platform is native (not web)
  static bool get isNative => !kIsWeb;

  /// Get current platform name for logging
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown';
  }
}
