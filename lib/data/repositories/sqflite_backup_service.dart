import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../domain/services/backup_service.dart';
import '../database/database_helper.dart';

class SqfliteBackupService implements BackupService {
  final DatabaseHelper _dbHelper;

  static const int currentFormatVersion = 1;

  SqfliteBackupService(this._dbHelper);

  @override
  Future<String> exportBackup() async {
    final db = await _dbHelper.database;

    final payload = <String, dynamic>{
      'format_version': currentFormatVersion,
      'app_version': '1.0.0', // Could be fetched via package_info
      'database_schema_version': 3,
      'exported_at': DateTime.now().toIso8601String(),
      'accounts': await db.query('accounts'),
      'categories': await db.query('categories'),
      'transactions': await db.query('transactions'),
      'debts': await db.query('debts'),
      'recurring_transactions': await db.query('recurring_transactions'),
      'budgets': await db.query('budgets'),
      'settings': await db.query('settings'),
    };

    final jsonString = jsonEncode(payload);

    // Add checksum
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);

    final backup = {'payload': jsonString, 'checksum': digest.toString()};

    return jsonEncode(backup);
  }

  @override
  Future<bool> validateBackup(String jsonContent) async {
    try {
      final backup = jsonDecode(jsonContent) as Map<String, dynamic>;
      final payloadString = backup['payload'] as String?;
      final checksum = backup['checksum'] as String?;

      if (payloadString == null || checksum == null) return false;

      final bytes = utf8.encode(payloadString);
      final digest = sha256.convert(bytes).toString();

      if (digest != checksum) return false; // Checksum failed

      final payload = jsonDecode(payloadString) as Map<String, dynamic>;

      if (payload['format_version'] != currentFormatVersion) return false;
      if (payload['database_schema_version'] > 3)
        return false; // Unsupported future schema

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> restoreBackup(String jsonContent) async {
    if (!await validateBackup(jsonContent)) {
      throw Exception(
        'Backup validation failed. File is corrupt or incompatible.',
      );
    }

    final backup = jsonDecode(jsonContent) as Map<String, dynamic>;
    final payload =
        jsonDecode(backup['payload'] as String) as Map<String, dynamic>;

    final db = await _dbHelper.database;

    // Use an atomic transaction
    await db.transaction((txn) async {
      // 1. Delete all existing data
      await txn.delete('transactions');
      await txn.delete('recurring_transactions');
      await txn.delete('budgets');
      await txn.delete('debts');
      await txn.delete('categories');
      await txn.delete('accounts');
      await txn.delete('settings');

      // 2. Insert accounts
      for (final map in payload['accounts'] as List) {
        await txn.insert('accounts', Map<String, dynamic>.from(map as Map));
      }

      // 3. Insert categories
      for (final map in payload['categories'] as List) {
        await txn.insert('categories', Map<String, dynamic>.from(map as Map));
      }

      // 4. Insert debts
      for (final map in payload['debts'] as List) {
        await txn.insert('debts', Map<String, dynamic>.from(map as Map));
      }

      // 5. Insert recurring rules
      for (final map in payload['recurring_transactions'] as List) {
        await txn.insert(
          'recurring_transactions',
          Map<String, dynamic>.from(map as Map),
        );
      }

      // 6. Insert budgets
      for (final map in payload['budgets'] as List) {
        await txn.insert('budgets', Map<String, dynamic>.from(map as Map));
      }

      // 7. Insert transactions (must be last due to foreign keys)
      for (final map in payload['transactions'] as List) {
        await txn.insert('transactions', Map<String, dynamic>.from(map as Map));
      }

      // 8. Insert settings
      for (final map in payload['settings'] as List) {
        await txn.insert('settings', Map<String, dynamic>.from(map as Map));
      }
    });
  }
}
