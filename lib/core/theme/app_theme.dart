import 'package:flutter/material.dart';

/// Cloudflare brand color
const Color cloudflareOrange = Color(0xFFF38020);

/// App theme configuration
class AppTheme {
  AppTheme._();

  // Internal constant for reuse
  static const Color _cloudflareOrange = cloudflareOrange;

  /// Light theme
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: cloudflareOrange,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Dark theme
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: cloudflareOrange,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// AMOLED theme (Pure black #000000 for maximum battery savings on OLED)
  static ThemeData get amoled {
    // AMOLED Theme: Pure black (#000) for maximum power saving on OLED screens
    // Reference: https://www.xda-developers.com/amoled-black-vs-gray-dark-mode/
    // Material Design uses #121212, but battery difference is only 0.3%
    // User requested #000000 explicitly - we mitigate "color vibration" with
    // subtle borders and desaturated accent colors

    final amoledColorScheme = ColorScheme.fromSeed(
      seedColor: _cloudflareOrange,
      brightness: Brightness.dark,
    ).copyWith(
      // Pure black backgrounds - OLED pixels turn off completely
      surface: const Color(0xFF000000),
      onSurface: const Color(0xFFFFFFFF),

      // Containers with very dark gray for visual hierarchy
      surfaceContainerHighest: const Color(0xFF1A1A1A), // 10% white
      surfaceContainer: const Color(0xFF121212), // 7% white
      surfaceContainerLow: const Color(0xFF0A0A0A), // 4% white

      // Subtle borders to avoid "color vibration" on pure black
      outline: const Color(0xFF404040),
      outlineVariant: const Color(0xFF2A2A2A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: amoledColorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: amoledColorScheme.surface,
        foregroundColor: amoledColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: amoledColorScheme.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: amoledColorScheme.primary,
        foregroundColor: amoledColorScheme.onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: amoledColorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Get theme based on mode
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}

/// Analytics chart colors
const List<Color> analyticsColors = [
  Color(0xFF1E88E5), // Blue
  Color(0xFFF57C00), // Orange
  Color(0xFF43A047), // Green
  Color(0xFFE91E63), // Pink
  Color(0xFF9C27B0), // Purple
  Color(0xFF00ACC1), // Cyan
  Color(0xFFFDD835), // Yellow
  Color(0xFFE53935), // Red
  Color(0xFF5E35B1), // Deep Purple
  Color(0xFF00897B), // Teal
];

/// Record type chip colors
Color getRecordTypeColor(String type) {
  return switch (type) {
    'A' => const Color(0xFF1E88E5),
    'AAAA' => const Color(0xFF7B1FA2),
    'CNAME' => const Color(0xFF388E3C),
    'TXT' => const Color(0xFFF57C00),
    'MX' => const Color(0xFFD32F2F),
    'SRV' => const Color(0xFF0097A7),
    'NS' => const Color(0xFF5D4037),
    'PTR' => const Color(0xFF455A64),
    _ => const Color(0xFF757575),
  };
}
