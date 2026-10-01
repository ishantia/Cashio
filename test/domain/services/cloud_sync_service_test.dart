import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:cashio/domain/services/cloud_sync_service.dart';
import 'package:cashio/domain/services/backup_service.dart';
import 'package:cashio/domain/services/encryption_service.dart';
import 'package:cashio/domain/services/key_management_service.dart';
import 'package:cashio/domain/repositories/cloud_backup_repository.dart';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockBackupService implements BackupService {
  @override
  Future<String> exportBackup() async => '{"test": "data"}';
  @override
  Future<void> restoreBackup(String json) async {}
  @override
  Future<bool> validateBackup(String json) async => true;
}

class MockCloudBackupRepository implements CloudBackupRepository {
  Uint8List? uploadedData;
  String? uploadedChecksum;

  @override
  Future<void> uploadBackup({
    required String backupId,
    required Uint8List encryptedData,
    required String checksum,
    required String appVersion,
    required String schemaVersion,
  }) async {
    uploadedData = encryptedData;
    uploadedChecksum = checksum;
  }

  @override
  Future<EncryptedBackup> downloadBackup(String backupId) async {
    return EncryptedBackup(uploadedData!, uploadedChecksum!);
  }

  @override
  Future<List<CloudBackupMetadata>> listBackups() async => [];

  @override
  Future<void> deleteBackup(String backupId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CloudSyncService full roundtrip', () async {
    SharedPreferences.setMockInitialValues({'automatic_backup_enabled': false});
    final prefs = await SharedPreferences.getInstance();

    // We mock secure storage to avoid platform channel exception
    FlutterSecureStorage.setMockInitialValues({});

    final localBackup = MockBackupService();
    final encryption = EncryptionService();
    final keyMgmt = KeyManagementService();
    await keyMgmt.generateAndStoreKeyFromPassword('testpassword');
    final cloudRepo = MockCloudBackupRepository();

    final syncService = CloudSyncService(
      localBackup,
      encryption,
      keyMgmt,
      cloudRepo,
      prefs,
    );

    await syncService.performCloudBackup();

    expect(cloudRepo.uploadedData, isNotNull);
    expect(cloudRepo.uploadedChecksum, isNotNull);

    // Test restore
    await syncService.restoreCloudBackup('backup_test');
  });
}
