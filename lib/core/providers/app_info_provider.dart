import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Provider for app package info (version, build number, etc.)
final appInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

/// Convenience provider for app version string
final appVersionProvider = Provider<String>((ref) {
  final info = ref.watch(appInfoProvider).valueOrNull;
  if (info == null) return 'Loading...';
  return '${info.version}+${info.buildNumber}';
});
