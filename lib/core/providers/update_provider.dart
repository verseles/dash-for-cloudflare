import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UpdateInstallState { idle, downloading, installing, done, failed }

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.latestVersion,
    this.releaseUrl,
    this.releaseNotes,
    this.apkUrl,
    required this.isNewer,
  });

  final String latestVersion;
  final String? releaseUrl;
  final String? releaseNotes;
  // Direct APK download URL from GitHub release assets (Android only).
  final String? apkUrl;
  final bool isNewer;
}

class UpdateState {
  const UpdateState({
    this.result,
    this.installState = UpdateInstallState.idle,
    this.installProgress = 0.0,
    this.checking = false,
    this.pendingStartupToast = false,
    this.dismissedVersion,
    this.checkOnOpen = true,
  });

  final UpdateCheckResult? result;
  final UpdateInstallState installState;
  final double installProgress;
  final bool checking;
  // Set after a startup check finds a newer version; consumed once by UI.
  final bool pendingStartupToast;
  final String? dismissedVersion;
  final bool checkOnOpen;

  bool get hasUpdate =>
      result != null &&
      result!.isNewer &&
      result!.latestVersion != dismissedVersion;

  UpdateState copyWith({
    UpdateCheckResult? result,
    UpdateInstallState? installState,
    double? installProgress,
    bool? checking,
    bool? pendingStartupToast,
    String? dismissedVersion,
    bool? checkOnOpen,
    bool clearResult = false,
    bool clearDismissedVersion = false,
  }) {
    return UpdateState(
      result: clearResult ? null : (result ?? this.result),
      installState: installState ?? this.installState,
      installProgress: installProgress ?? this.installProgress,
      checking: checking ?? this.checking,
      pendingStartupToast: pendingStartupToast ?? this.pendingStartupToast,
      dismissedVersion:
          clearDismissedVersion
              ? null
              : (dismissedVersion ?? this.dismissedVersion),
      checkOnOpen: checkOnOpen ?? this.checkOnOpen,
    );
  }
}

const String _repoOwner = 'verseles';
const String _repoName = 'dash-for-cloudflare';
const Duration _cooldown = Duration(hours: 1);
const String _keyDismissedVersion = 'update_dismissed_version';
const String _keyCheckOnOpen = 'update_check_on_open';

/// Riverpod notifier managing update check and in-app install state.
class UpdateNotifier extends Notifier<UpdateState> {
  DateTime? _lastCheck;

  @override
  UpdateState build() {
    // Load persisted preferences asynchronously after first build.
    Future.microtask(_loadPersistedState);
    return const UpdateState();
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      dismissedVersion: prefs.getString(_keyDismissedVersion),
      checkOnOpen: prefs.getBool(_keyCheckOnOpen) ?? true,
    );
  }

  Future<void> setCheckOnOpen(bool value) async {
    state = state.copyWith(checkOnOpen: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCheckOnOpen, value);
  }

  /// Silent startup check — sets pendingStartupToast if a newer version is found.
  Future<void> performStartupCheck() async {
    if (!state.checkOnOpen) return;
    final info = await PackageInfo.fromPlatform();
    final result = await _check(info.version);
    if (result != null &&
        result.isNewer &&
        result.latestVersion != state.dismissedVersion) {
      state = state.copyWith(pendingStartupToast: true);
    }
  }

  /// Called by UI after showing the startup toast — prevents duplicate toasts.
  void acknowledgeStartupToast() {
    state = state.copyWith(pendingStartupToast: false);
  }

  /// Manual update check — shows spinner while in progress.
  Future<void> checkForUpdate() async {
    if (state.checking) return;
    state = state.copyWith(checking: true);
    final info = await PackageInfo.fromPlatform();
    await _check(info.version);
    state = state.copyWith(checking: false);
  }

  Future<UpdateCheckResult?> _check(String currentVersion) async {
    if (_lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < _cooldown) {
      return state.result;
    }

    try {
      final current = _parseSemver(currentVersion);
      if (current == null) return null;

      final response = await Dio().get<Map<String, dynamic>>(
        'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest',
        options: Options(
          headers: {
            'Accept': 'application/vnd.github+json',
            'User-Agent': 'DashForCF',
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      final data = response.data;
      if (data == null) return null;

      final tagName = data['tag_name'] as String?;
      if (tagName == null) return null;

      final latest = _parseSemver(tagName);
      if (latest == null) return null;

      String? apkUrl;
      final assets = data['assets'];
      if (assets is List) {
        for (final asset in assets) {
          final name = (asset['name'] as String?) ?? '';
          if (name.endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String?;
            break;
          }
        }
      }

      _lastCheck = DateTime.now();
      final result = UpdateCheckResult(
        latestVersion: latest.join('.'),
        releaseUrl: data['html_url'] as String?,
        releaseNotes: data['body'] as String?,
        apkUrl: apkUrl,
        isNewer: _isNewer(latest, current),
      );
      state = state.copyWith(result: result);
      return result;
    } catch (e) {
      debugPrint('UpdateNotifier: check failed: $e');
      return null;
    }
  }

  List<int>? _parseSemver(String input) {
    var cleaned = input.trim().replaceFirst(RegExp(r'^v'), '');
    final dashIdx = cleaned.indexOf('-');
    if (dashIdx != -1) cleaned = cleaned.substring(0, dashIdx);
    final plusIdx = cleaned.indexOf('+');
    if (plusIdx != -1) cleaned = cleaned.substring(0, plusIdx);
    final parts = cleaned.split('.');
    if (parts.length != 3) return null;
    final nums = parts.map(int.tryParse).toList();
    if (nums.any((n) => n == null)) return null;
    return nums.cast<int>();
  }

  bool _isNewer(List<int> a, List<int> b) {
    for (int i = 0; i < 3; i++) {
      if (a[i] != b[i]) return a[i] > b[i];
    }
    return false;
  }

  Future<void> dismissUpdate() async {
    final version = state.result?.latestVersion;
    if (version == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDismissedVersion, version);
    state = state.copyWith(
      dismissedVersion: version,
      installState: UpdateInstallState.idle,
      installProgress: 0.0,
    );
  }

  /// Initiates platform-specific installation. Resets to idle first so UI guards clear.
  Future<void> startInstall() async {
    if (state.installState == UpdateInstallState.downloading ||
        state.installState == UpdateInstallState.installing) return;
    // Reset to idle so guard flags in the UI clear before a new cycle.
    state = state.copyWith(
      installState: UpdateInstallState.idle,
      installProgress: 0.0,
    );

    final result = state.result;
    if (result == null) return;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _installAndroid(result);
    } else {
      await _installDesktop();
    }
  }

  Future<void> _installAndroid(UpdateCheckResult result) async {
    if (result.apkUrl == null) return;
    state = state.copyWith(
      installState: UpdateInstallState.downloading,
      installProgress: 0.0,
    );

    final destPath =
        '${(await getTemporaryDirectory()).path}/dash-for-cf-update.apk';
    try {
      await Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(minutes: 10),
        ),
      ).download(
        result.apkUrl!,
        destPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            state = state.copyWith(installProgress: received / total);
          }
        },
      );

      state = state.copyWith(installState: UpdateInstallState.installing);
      await OpenFilex.open(destPath);
    } catch (e) {
      debugPrint('UpdateNotifier: APK download/install failed: $e');
      try {
        File(destPath).deleteSync();
      } catch (_) {}
      state = state.copyWith(installState: UpdateInstallState.failed);
    }
  }

  Future<void> _installDesktop() async {
    state = state.copyWith(installState: UpdateInstallState.installing);

    try {
      final ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run(
          'powershell',
          ['-c', 'irm install.cat/verseles/dash-for-cf | iex'],
        ).timeout(const Duration(minutes: 5));
      } else {
        result = await Process.run(
          'sh',
          ['-c', 'curl -fsSL install.cat/verseles/dash-for-cf | sh'],
        ).timeout(const Duration(minutes: 5));
      }
      state = state.copyWith(
        installState:
            result.exitCode == 0
                ? UpdateInstallState.done
                : UpdateInstallState.failed,
      );
    } catch (e) {
      debugPrint('UpdateNotifier: desktop install failed: $e');
      state = state.copyWith(installState: UpdateInstallState.failed);
    }
  }
}

/// Provider for app update state and install actions.
final updateProvider =
    NotifierProvider<UpdateNotifier, UpdateState>(UpdateNotifier.new);
