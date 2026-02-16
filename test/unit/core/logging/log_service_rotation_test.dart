import 'dart:io';

import 'package:cf/core/logging/log_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String appDocPath;

  MockPathProviderPlatform(this.appDocPath);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return appDocPath;
  }
}

void main() {
  late Directory tempDir;
  late Directory logsDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('log_test');
    logsDir = Directory('${tempDir.path}/logs');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);
  });

  tearDown(() async {
    await LogService.instance.setFileLoggingEnabled(false);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('LogService rotates old files correctly', () async {
    // create old file (8 days ago)
    final oldFile = File('${logsDir.path}/old.log');
    await oldFile.writeAsString('old log content');
    final oldTime = DateTime.now().subtract(const Duration(days: 8));
    await oldFile.setLastModified(oldTime);

    // create new file (1 day ago)
    final newFile = File('${logsDir.path}/new.log');
    await newFile.writeAsString('new log content');
    final newTime = DateTime.now().subtract(const Duration(days: 1));
    await newFile.setLastModified(newTime);

    // Enable file logging, which triggers rotation
    await LogService.instance.setFileLoggingEnabled(true);

    // Verify old file deleted
    expect(await oldFile.exists(), isFalse, reason: 'Old file should be deleted');
    expect(await newFile.exists(), isTrue, reason: 'New file should remain');
  });

  test('LogService rotates large total size correctly', () async {
    // Create huge files
    // 15MB file (older)
    final file1 = File('${logsDir.path}/file1.log');
    final raf1 = await file1.open(mode: FileMode.write);
    await raf1.truncate(15 * 1024 * 1024);
    await raf1.close();

    final time1 = DateTime.now().subtract(const Duration(hours: 2));
    await file1.setLastModified(time1);

    // 10MB file (newer)
    final file2 = File('${logsDir.path}/file2.log');
    final raf2 = await file2.open(mode: FileMode.write);
    await raf2.truncate(10 * 1024 * 1024);
    await raf2.close();

    final time2 = DateTime.now().subtract(const Duration(hours: 1));
    await file2.setLastModified(time2);

    // Total 25MB > 20MB limit.
    // Should delete oldest (file1) until total <= 10MB.
    // 25 - 15 = 10MB. file2 remains.

    await LogService.instance.setFileLoggingEnabled(true);

    expect(await file1.exists(), isFalse, reason: 'Oldest large file should be deleted');
    expect(await file2.exists(), isTrue, reason: 'Newest file should remain');
  });
}
