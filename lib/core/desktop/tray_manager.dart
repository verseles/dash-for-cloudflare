import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';

import 'window_manager.dart';

/// System tray manager for desktop platforms
class DesktopTrayManager with TrayListener {
  DesktopTrayManager._();

  static DesktopTrayManager? _instance;
  static DesktopTrayManager get instance {
    _instance ??= DesktopTrayManager._();
    return _instance!;
  }

  bool _isInitialized = false;

  /// Initialize system tray
  Future<void> initialize() async {
    if (!DesktopWindowManager.isDesktop || _isInitialized) return;

    try {
      // Set tray icon based on platform
      String iconPath;
      if (Platform.isWindows) {
        iconPath = 'assets/icons/icon.ico';
      } else {
        iconPath = 'assets/icons/icon.png';
      }

      await trayManager.setIcon(iconPath);
      await trayManager.setToolTip('Dash for CF');

      // Create context menu
      final menu = Menu(
        items: [
          MenuItem(key: 'show', label: 'Show'),
          MenuItem.separator(),
          MenuItem(key: 'quit', label: 'Quit'),
        ],
      );
      await trayManager.setContextMenu(menu);

      // Add listener
      trayManager.addListener(this);
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize system tray: $e');
      }
    }
  }

  /// Dispose tray manager
  Future<void> dispose() async {
    if (!_isInitialized) return;
    trayManager.removeListener(this);
    await trayManager.destroy();
    _isInitialized = false;
  }

  @override
  void onTrayIconMouseDown() {
    // Show window on click
    DesktopWindowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    // Show context menu on right click
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        DesktopWindowManager.show();
        break;
      case 'quit':
        DesktopWindowManager.close();
        break;
    }
  }

  @override
  void onTrayIconMouseUp() {}

  @override
  void onTrayIconRightMouseUp() {}
}
