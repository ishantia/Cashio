import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:cashio/domain/repositories/cloud_backup_repository.dart';
import 'package:cashio/domain/services/key_management_service.dart';

class CloudflareBackupRepository implements CloudBackupRepository {
  final KeyManagementService _keyManagement;
  final http.Client _client;

  CloudflareBackupRepository(this._keyManagement, {http.Client? client})
    : _client = client ?? http.Client();

  Future<Map<String, String>> _getAuthHeaders() async {
    final settings = await _keyManagement.getCloudSettings();
    final token = settings['api_token'];
    final userId = settings['user_id'];

    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      throw CloudAuthenticationException(
        'Cloud backup is not fully configured (missing token or user ID).',
      );
    }

    return {'Authorization': 'Bearer $token', 'X-User-Id': userId};
  }

  Future<String> _getBaseUrl() async {
    final settings = await _keyManagement.getCloudSettings();
    final url = settings['worker_url'];
    if (url == null || url.isEmpty) {
      throw CloudAuthenticationException('Worker URL is not configured.');
    }
    // Remove trailing slash if present
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  @override
  Future<void> uploadBackup({
    required String backupId,
    required Uint8List encryptedData,
    required String checksum,
    required String appVersion,
    required String schemaVersion,
  }) async {
    try {
      final baseUrl = await _getBaseUrl();
      final headers = await _getAuthHeaders();

      headers.addAll({
        'X-Backup-Id': backupId,
        'X-Created-At': DateTime.now().toUtc().toIso8601String(),
        'X-App-Version': appVersion,
        'X-Backup-Format-Version': '1',
        'X-Schema-Version': schemaVersion,
        'X-Checksum': checksum,
        'X-Encryption-Version': '1',
        'Content-Type': 'application/octet-stream',
      });

      final response = await _client.post(
        Uri.parse('$baseUrl/v1/backups'),
        headers: headers,
        body: encryptedData,
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw CloudAuthenticationException('Unauthorized to upload backup.');
      }

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw CloudNetworkException(
          'Failed to upload backup. Status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw CloudNetworkException(
        'No internet connection or server unreachable.',
      );
    } catch (e) {
      if (e is CloudAuthenticationException || e is CloudNetworkException) {
        rethrow;
      }
      throw CloudNetworkException('Unexpected error during upload: $e');
    }
  }

  @override
  Future<List<CloudBackupMetadata>> listBackups() async {
    try {
      final baseUrl = await _getBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await _client.get(
        Uri.parse('$baseUrl/v1/backups'),
        headers: headers,
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw CloudAuthenticationException('Unauthorized to list backups.');
      }

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final backupsList = jsonBody['backups'] as List;
        return backupsList.map((e) => CloudBackupMetadata.fromJson(e)).toList();
      } else {
        throw CloudNetworkException(
          'Failed to list backups. Status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw CloudNetworkException(
        'No internet connection or server unreachable.',
      );
    } catch (e) {
      if (e is CloudAuthenticationException || e is CloudNetworkException) {
        rethrow;
      }
      throw CloudNetworkException('Unexpected error listing backups: $e');
    }
  }

  @override
  Future<EncryptedBackup> downloadBackup(String backupId) async {
    try {
      final baseUrl = await _getBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await _client.get(
        Uri.parse('$baseUrl/v1/backups/$backupId'),
        headers: headers,
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw CloudAuthenticationException('Unauthorized to download backup.');
      }

      if (response.statusCode == 404) {
        throw CloudBackupNotFoundException(backupId);
      }

      if (response.statusCode == 200) {
        final checksum = response.headers['x-checksum'] ?? '';
        return EncryptedBackup(response.bodyBytes, checksum);
      } else {
        throw CloudNetworkException(
          'Failed to download backup. Status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw CloudNetworkException(
        'No internet connection or server unreachable.',
      );
    } catch (e) {
      if (e is CloudAuthenticationException ||
          e is CloudBackupNotFoundException ||
          e is CloudNetworkException) {
        rethrow;
      }
      throw CloudNetworkException('Unexpected error downloading backup: $e');
    }
  }

  @override
  Future<void> deleteBackup(String backupId) async {
    try {
      final baseUrl = await _getBaseUrl();
      final headers = await _getAuthHeaders();

      final response = await _client.delete(
        Uri.parse('$baseUrl/v1/backups/$backupId'),
        headers: headers,
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw CloudAuthenticationException('Unauthorized to delete backup.');
      }

      if (response.statusCode != 200) {
        throw CloudNetworkException(
          'Failed to delete backup. Status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw CloudNetworkException(
        'No internet connection or server unreachable.',
      );
    } catch (e) {
      if (e is CloudAuthenticationException || e is CloudNetworkException) {
        rethrow;
      }
      throw CloudNetworkException('Unexpected error deleting backup: $e');
    }
  }
}
