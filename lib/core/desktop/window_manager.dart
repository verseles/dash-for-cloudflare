import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

/// Desktop window configuration
class DesktopWindowManager {
  DesktopWindowManager._();

  static const Size _initialSize = Size(1200, 800);
  static const Size _minimumSize = Size(800, 600);
  static const String _windowTitle = 'Dash for Cloudflare';

  /// Initialize window manager for desktop platforms
  static Future<void> initialize() async {
    // Only run on desktop platforms
    if (kIsWeb || !_isDesktop) return;

    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: _initialSize,
      minimumSize: _minimumSize,
      center: true,
      backgroundColor: const Color(0x00000000),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: _windowTitle,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// Check if running on a desktop platform
  static bool get _isDesktop {
    return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  }

  /// Check if we should use desktop features
  static bool get isDesktop {
    if (kIsWeb) return false;
    return _isDesktop;
  }

  /// Set window title dynamically
  static Future<void> setTitle(String title) async {
    if (!isDesktop) return;
    await windowManager.setTitle(title);
  }

  /// Set window title with zone name
  static Future<void> setTitleWithZone(String? zoneName) async {
    if (!isDesktop) return;
    final title = zoneName != null ? '$zoneName - $_windowTitle' : _windowTitle;
    await windowManager.setTitle(title);
  }

  /// Show the window
  static Future<void> show() async {
    if (!isDesktop) return;
    await windowManager.show();
    await windowManager.focus();
  }

  /// Hide the window
  static Future<void> hide() async {
    if (!isDesktop) return;
    await windowManager.hide();
  }

  /// Minimize the window
  static Future<void> minimize() async {
    if (!isDesktop) return;
    await windowManager.minimize();
  }

  /// Restore the window from minimized state
  static Future<void> restore() async {
    if (!isDesktop) return;
    await windowManager.restore();
  }

  /// Close the window/app
  static Future<void> close() async {
    if (!isDesktop) return;
    await windowManager.close();
  }

  /// Toggle fullscreen
  static Future<void> toggleFullscreen() async {
    if (!isDesktop) return;
    final isFullscreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullscreen);
  }
}
