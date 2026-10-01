import 'dart:typed_data';

class CloudBackupMetadata {
  final String backupId;
  final int size;
  final DateTime createdAt;
  final String appVersion;
  final String backupFormatVersion;
  final String schemaVersion;
  final String checksum;
  final String encryptionVersion;

  CloudBackupMetadata({
    required this.backupId,
    required this.size,
    required this.createdAt,
    required this.appVersion,
    required this.backupFormatVersion,
    required this.schemaVersion,
    required this.checksum,
    required this.encryptionVersion,
  });

  factory CloudBackupMetadata.fromJson(Map<String, dynamic> json) {
    return CloudBackupMetadata(
      backupId: json['backup_id'] as String,
      size: json['size'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      appVersion: json['app_version'] as String? ?? 'unknown',
      backupFormatVersion: json['backup_format_version'] as String? ?? '1',
      schemaVersion: json['schema_version'] as String? ?? '1',
      checksum: json['checksum'] as String? ?? '',
      encryptionVersion: json['encryption_version'] as String? ?? '1',
    );
  }
}

class EncryptedBackup {
  final Uint8List data;
  final String checksum;

  EncryptedBackup(this.data, this.checksum);
}

abstract class CloudBackupRepository {
  Future<void> uploadBackup({
    required String backupId,
    required Uint8List encryptedData,
    required String checksum,
    required String appVersion,
    required String schemaVersion,
  });

  Future<List<CloudBackupMetadata>> listBackups();

  Future<EncryptedBackup> downloadBackup(String backupId);

  Future<void> deleteBackup(String backupId);
}

class CloudAuthenticationException implements Exception {
  final String message;
  CloudAuthenticationException(this.message);
  @override
  String toString() => 'CloudAuthenticationException: $message';
}

class CloudNetworkException implements Exception {
  final String message;
  CloudNetworkException(this.message);
  @override
  String toString() => 'CloudNetworkException: $message';
}

class CloudBackupNotFoundException implements Exception {
  final String backupId;
  CloudBackupNotFoundException(this.backupId);
  @override
  String toString() =>
      'CloudBackupNotFoundException: Backup $backupId not found';
}
