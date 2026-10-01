import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cashio/domain/services/encryption_service.dart';

void main() {
  late EncryptionService encryptionService;
  late SecretKey testKey;
  final plaintext = utf8.encode('Hello, Cashio Cloud Backup!');

  setUpAll(() async {
    encryptionService = EncryptionService();
    final algorithm = AesGcm.with256bits();
    testKey = await algorithm.newSecretKey();
  });

  test('encrypt and decrypt round trip', () async {
    final encryptedData = await encryptionService.encrypt(plaintext, testKey);
    final decryptedData = await encryptionService.decrypt(
      encryptedData,
      testKey,
    );

    expect(decryptedData, equals(plaintext));
  });

  test('wrong key fails decryption', () async {
    final encryptedData = await encryptionService.encrypt(plaintext, testKey);
    final wrongKey = await AesGcm.with256bits().newSecretKey();

    expect(
      () => encryptionService.decrypt(encryptedData, wrongKey),
      throwsA(isA<EncryptionException>()),
    );
  });

  test('modified ciphertext fails authentication', () async {
    final encryptedData = await encryptionService.encrypt(plaintext, testKey);

    // Modify last byte (ciphertext part)
    encryptedData[encryptedData.length - 1] ^= 0x01;

    expect(
      () => encryptionService.decrypt(encryptedData, testKey),
      throwsA(isA<EncryptionException>()),
    );
  });

  test('unsupported encryption version rejected', () async {
    final encryptedData = await encryptionService.encrypt(plaintext, testKey);

    // Modify version byte
    encryptedData[0] = 99;

    expect(
      () => encryptionService.decrypt(encryptedData, testKey),
      throwsA(
        isA<EncryptionException>().having(
          (e) => e.message,
          'message',
          contains('Unsupported encryption version'),
        ),
      ),
    );
  });
}
