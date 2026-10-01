import 'dart:convert';
import 'dart:typed_data';

import 'package:cashio/domain/services/backup_service.dart';
import 'package:cashio/domain/services/encryption_service.dart';
import 'package:cashio/domain/services/key_management_service.dart';
import 'package:cashio/domain/repositories/cloud_backup_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupChecksumMismatchException implements Exception {
  final String message;
  BackupChecksumMismatchException(this.message);
  @override
  String toString() => 'BackupChecksumMismatchException: $message';
}

class CloudSyncService {
  final BackupService _localBackupService;
  final EncryptionService _encryptionService;
  final KeyManagementService _keyManagementService;
  final CloudBackupRepository _cloudBackupRepository;
  final SharedPreferences _prefs;

  CloudSyncService(
    this._localBackupService,
    this._encryptionService,
    this._keyManagementService,
    this._cloudBackupRepository,
    this._prefs,
  );

  /// Performs a full cloud backup. Returns true if a backup was uploaded, false if deduplicated.
  Future<bool> performCloudBackup({bool isAutomatic = false}) async {
    // 1. Get canonical backup JSON string
    final backupJson = await _localBackupService.exportBackup();
    final plaintextData = utf8.encode(backupJson) as Uint8List;

    // Deduplication check
    final plaintextChecksum = sha256.convert(plaintextData).toString();
    final lastPlaintextChecksum = _prefs.getString('last_canonical_checksum');

    if (isAutomatic && lastPlaintextChecksum == plaintextChecksum) {
      // Data hasn't changed, skip upload
      return false;
    }

    // 2. Encrypt
    final key = await _keyManagementService.getKey();
    if (key == null) {
      throw CloudAuthenticationException('Encryption key not configured.');
    }

    final encryptedData = await _encryptionService.encrypt(plaintextData, key);

    // 3. Calculate Checksum (SHA-256 over encrypted data, matching Phase 5A behavior)
    final checksum = sha256.convert(encryptedData).toString();

    // 4. Generate Backup ID
    final backupId =
        'backup_' + DateTime.now().millisecondsSinceEpoch.toString();

    // 5. Upload to Cloud
    await _cloudBackupRepository.uploadBackup(
      backupId: backupId,
      encryptedData: encryptedData,
      checksum: checksum,
      appVersion: '1.0.0',
      schemaVersion: '4',
    );

    // Save successful checksum for future deduplication
    await _prefs.setString('last_canonical_checksum', plaintextChecksum);

    return true;
  }

  /// Restores a cloud backup locally.
  Future<void> restoreCloudBackup(String backupId) async {
    // 1. Download
    final encryptedBackup = await _cloudBackupRepository.downloadBackup(
      backupId,
    );

    // 2. Verify Checksum
    final actualChecksum = sha256.convert(encryptedBackup.data).toString();
    if (actualChecksum != encryptedBackup.checksum) {
      throw BackupChecksumMismatchException(
        'Checksum verification failed. Backup may be corrupted or modified.',
      );
    }

    // 3. Decrypt
    final key = await _keyManagementService.getKey();
    if (key == null) {
      throw CloudAuthenticationException('Encryption key not configured.');
    }

    final decryptedData = await _encryptionService.decrypt(
      encryptedBackup.data,
      key,
    );
    final backupJson = utf8.decode(decryptedData);

    // 4. Local Restore
    final isValid = await _localBackupService.validateBackup(backupJson);
    if (!isValid) throw Exception('Invalid backup format after decryption');
    await _localBackupService.restoreBackup(backupJson);
  }

  /// Enforces the backup retention policy
  Future<void> enforceRetentionPolicy() async {
    try {
      final retentionCount = _prefs.getInt('backup_retention_count') ?? 10;
      final backups = await _cloudBackupRepository.listBackups();

      if (backups.length <= retentionCount) return;

      // Sort by created_at descending (newest first)
      backups.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });

      // Delete older backups
      final toDelete = backups.sublist(retentionCount);
      for (final backup in toDelete) {
        try {
          await _cloudBackupRepository.deleteBackup(backup.backupId);
        } catch (e) {
          // Log cleanup failure, but don't fail the sync process
          print('Cleanup failed for backup ${backup.backupId}: $e');
        }
      }
    } catch (e) {
      print('Retention policy enforcement failed: $e');
    }
  }
}
