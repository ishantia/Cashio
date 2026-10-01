import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyManagementService {
  final _storage = const FlutterSecureStorage();
  static const _keyAlias = 'cashio_cloud_backup_key';
  static const _apiTokenAlias = 'cashio_cloud_api_token';
  static const _workerUrlAlias = 'cashio_cloud_worker_url';
  static const _userIdAlias = 'cashio_cloud_user_id';

  Future<bool> hasKey() async {
    return await _storage.containsKey(key: _keyAlias);
  }

  Future<void> generateAndStoreKeyFromPassword(String password) async {
    // Argon2id
    final algorithm = Argon2id(
      memory: 19456, // 19 MB
      iterations: 2,
      parallelism: 1,
      hashLength: 32,
    );

    // Provide a static salt or generated salt. For backup we can just use a fixed app salt
    // because the key itself never leaves the device. If the key left the device, we'd need random salts per password.
    final salt = utf8.encode('cashio_cloud_backup_salt_2026');

    final secretKey = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    final keyBytes = await secretKey.extractBytes();
    final keyBase64 = base64Encode(keyBytes);

    await _storage.write(key: _keyAlias, value: keyBase64);
  }

  Future<SecretKey?> getKey() async {
    final keyBase64 = await _storage.read(key: _keyAlias);
    if (keyBase64 == null) return null;
    return SecretKey(base64Decode(keyBase64));
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _keyAlias);
    await _storage.delete(key: _apiTokenAlias);
    await _storage.delete(key: _workerUrlAlias);
    await _storage.delete(key: _userIdAlias);
  }

  Future<void> saveCloudSettings(
    String token,
    String url,
    String userId,
  ) async {
    await _storage.write(key: _apiTokenAlias, value: token);
    await _storage.write(key: _workerUrlAlias, value: url);
    await _storage.write(key: _userIdAlias, value: userId);
  }

  Future<Map<String, String?>> getCloudSettings() async {
    return {
      'api_token': await _storage.read(key: _apiTokenAlias),
      'worker_url': await _storage.read(key: _workerUrlAlias),
      'user_id': await _storage.read(key: _userIdAlias),
    };
  }
}
