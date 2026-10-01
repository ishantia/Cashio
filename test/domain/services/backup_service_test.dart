import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cashio/data/database/database_helper.dart';
import 'package:cashio/data/repositories/sqflite_backup_service.dart';
import 'package:cashio/data/repositories/sqflite_account_repository.dart';
import 'package:cashio/domain/models/account.dart';
import 'package:cashio/domain/models/currency.dart';

void main() {
  late DatabaseHelper dbHelper;
  late SqfliteBackupService backupService;
  late SqfliteAccountRepository accountRepo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final path = await getDatabasesPath();
    // removed

    dbHelper = DatabaseHelper.instance;
    backupService = SqfliteBackupService(dbHelper);
    accountRepo = SqfliteAccountRepository(dbHelper);

    final db = await dbHelper.database;
    await db.delete('transactions');
    await db.delete('accounts');
    await db.delete('categories');
    await db.delete('debts');
    await db.delete('recurring_transactions');
    await db.delete('budgets');
  });

  test('Export -> Import round trip preserves entities atomically', () async {
    // 1. Create an account
    final acc = Account(
      id: 'acc_backup_1',
      name: 'Backup Test Account',
      currency: Currency.usd,
      initialBalance: 500,
      currentBalance: 500,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await accountRepo.createAccount(acc);

    // 2. Export backup
    final backupJson = await backupService.exportBackup();

    // 3. Verify backup is valid
    expect(await backupService.validateBackup(backupJson), isTrue);

    // 4. Corrupt the database
    await accountRepo.deleteAccount(acc.id);
    final emptyAccs = await accountRepo.getAllAccounts();
    expect(emptyAccs.isEmpty, isTrue);

    // 5. Restore backup
    await backupService.restoreBackup(backupJson);

    // 6. Verify restored
    final restoredAccs = await accountRepo.getAllAccounts();
    expect(restoredAccs.length, 1);
    expect(restoredAccs.first.name, 'Backup Test Account');
  });

  test('Invalid backup is rejected gracefully', () async {
    final badJson = '{"payload": "{}", "checksum": "wrong_checksum"}';

    expect(await backupService.validateBackup(badJson), isFalse);

    expect(
      () => backupService.restoreBackup(badJson),
      throwsA(isA<Exception>()),
    );
  });
  test('Restore rolls back atomically on invalid schema/data', () async {
    // 1. Create a baseline account
    final acc = Account(
      id: 'acc_baseline',
      name: 'Baseline Account',
      currency: Currency.usd,
      initialBalance: 100,
      currentBalance: 100,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await accountRepo.createAccount(acc);

    // 2. Prepare a completely corrupted JSON string that fails midway
    // It has valid JSON syntax but maybe fails foreign keys or invalid types
    // Actually, let's just break the JSON syntax entirely
    final badJson =
        '{"payload": {"accounts": [{"id": "bad", "name": "bad"}]}, "checksum": "valid_if_bypassed"}';
    // Let's create a technically valid structure that fails SQL insertion to trigger rollback.
    // e.g. missing required fields like currency_code
    final sqlFailingJson =
        '{"format_version": 1, "app_version": "1.0", "schema_version": 3, "exported_at": "2026-01-01T00:00:00.000", "payload": {"accounts": [{"id": "acc_bad", "name": "Bad"}]}}';

    try {
      await backupService.restoreBackup(sqlFailingJson);
      fail('Should have thrown an exception');
    } catch (e) {
      // Expected exception
    }

    // 3. Verify original database is untouched
    final accs = await accountRepo.getAllAccounts();
    expect(accs.length, 1);
    expect(accs.first.id, 'acc_baseline');
  });
}
