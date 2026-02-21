import 'dart:io';

import 'package:cf/core/logging/log_service.dart';
import 'package:cf/core/logging/log_level.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LogService Rotation', () {
    late LogService logService;
    late Directory tempDir;
    late MockPathProviderPlatform mockPathProvider;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('log_test_');
      mockPathProvider = MockPathProviderPlatform();

      // Setup mock
      when(() => mockPathProvider.getApplicationDocumentsPath())
          .thenAnswer((_) async => tempDir.path);

      PathProviderPlatform.instance = mockPathProvider;

      logService = LogService.instance;
      // Ensure clean state
      await logService.setFileLoggingEnabled(false);
      logService.clear();
    });

    tearDown(() async {
      await logService.setFileLoggingEnabled(false);
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Rotates old logs (older than 7 days)', () async {
      final logsDir = Directory('${tempDir.path}/logs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      // Create old file
      final oldFile = File('${logsDir.path}/app_old.log');
      await oldFile.writeAsString('old log content');
      final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
      await oldFile.setLastModified(eightDaysAgo);

      // Create new file
      final newFile = File('${logsDir.path}/app_new.log');
      await newFile.writeAsString('new log content');

      // Trigger rotation by enabling file logging
      await logService.setFileLoggingEnabled(true);

      expect(await oldFile.exists(), isFalse);
      expect(await newFile.exists(), isTrue);
    });

    test('Rotates logs by size (limit 20MB -> 10MB)', () async {
      final logsDir = Directory('${tempDir.path}/logs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      // Create 3 large files, 8MB each. Total 24MB.
      // We need to manipulate creation time so we know which one is oldest.

      final file1 = File('${logsDir.path}/app_1.log');
      await file1.writeAsBytes(List.filled(8 * 1024 * 1024, 0)); // 8MB
      await file1.setLastModified(DateTime.now().subtract(const Duration(hours: 3)));

      final file2 = File('${logsDir.path}/app_2.log');
      await file2.writeAsBytes(List.filled(8 * 1024 * 1024, 0)); // 8MB
      await file2.setLastModified(DateTime.now().subtract(const Duration(hours: 2)));

      final file3 = File('${logsDir.path}/app_3.log');
      await file3.writeAsBytes(List.filled(8 * 1024 * 1024, 0)); // 8MB
      await file3.setLastModified(DateTime.now().subtract(const Duration(hours: 1)));

      // Trigger rotation
      await logService.setFileLoggingEnabled(true);

      // Total was 24MB. Should delete oldest until <= 10MB.
      // Removing file1 (8MB) -> 16MB. Still > 10MB.
      // Removing file2 (8MB) -> 8MB. OK.

      expect(await file1.exists(), isFalse, reason: 'Oldest file should be deleted');
      expect(await file2.exists(), isFalse, reason: 'Second oldest file should be deleted to reach < 10MB');
      expect(await file3.exists(), isTrue, reason: 'Newest file should remain');
    });
  });
}
