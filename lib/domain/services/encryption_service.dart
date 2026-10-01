import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);
  @override
  String toString() => 'EncryptionException: $message';
}

class EncryptionService {
  // Use AES-256-GCM for authenticated encryption
  final _algorithm = AesGcm.with256bits();

  /// Encrypts the payload with the given key.
  /// Returns a concatenated byte array:
  /// [1 byte version][12 bytes nonce][ciphertext length][mac 16 bytes]
  Future<Uint8List> encrypt(Uint8List plaintext, SecretKey key) async {
    try {
      final secretBox = await _algorithm.encrypt(plaintext, secretKey: key);

      final version = Uint8List.fromList([1]); // Encryption version 1
      final nonce = Uint8List.fromList(secretBox.nonce);
      final mac = Uint8List.fromList(secretBox.mac.bytes);
      final ciphertext = Uint8List.fromList(secretBox.cipherText);

      final result = BytesBuilder();
      result.add(version);
      result.add(nonce);
      result.add(mac);
      result.add(ciphertext);

      return result.toBytes();
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Decrypts the payload with the given key.
  Future<Uint8List> decrypt(Uint8List encryptedData, SecretKey key) async {
    try {
      if (encryptedData.isEmpty) throw EncryptionException('Data is empty');

      final version = encryptedData[0];
      if (version != 1) {
        throw EncryptionException('Unsupported encryption version: $version');
      }

      // Format: [version 1 byte][nonce 12 bytes][mac 16 bytes][ciphertext...]
      if (encryptedData.length < 1 + 12 + 16) {
        throw EncryptionException('Invalid encrypted data format');
      }

      final nonce = encryptedData.sublist(1, 13);
      final mac = Mac(encryptedData.sublist(13, 29));
      final ciphertext = encryptedData.sublist(29);

      final secretBox = SecretBox(ciphertext, nonce: nonce, mac: mac);

      final plaintext = await _algorithm.decrypt(secretBox, secretKey: key);

      return Uint8List.fromList(plaintext);
    } catch (e) {
      if (e is EncryptionException) rethrow;
      throw EncryptionException(
        'Decryption failed. Incorrect key or corrupted data.',
      );
    }
  }
}
