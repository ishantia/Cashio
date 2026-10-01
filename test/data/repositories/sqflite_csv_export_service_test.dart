import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cashio/data/database/database_helper.dart';
import 'package:cashio/data/repositories/sqflite_csv_export_service.dart';
import 'package:cashio/data/repositories/sqflite_account_repository.dart';
import 'package:cashio/domain/repositories/transaction_repository.dart';
import 'package:cashio/data/repositories/sqflite_transaction_repository.dart';
import 'package:cashio/domain/models/account.dart';
import 'package:cashio/domain/models/currency.dart';
import 'package:cashio/domain/models/transaction.dart' as app_tx;

void main() {
  late DatabaseHelper dbHelper;
  late SqfliteCsvExportService csvService;
  late SqfliteAccountRepository accountRepo;
  late TransactionRepository txRepo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    csvService = SqfliteCsvExportService(dbHelper);
    accountRepo = SqfliteAccountRepository(dbHelper);
    txRepo = SqfliteTransactionRepository(dbHelper);

    final db = await dbHelper.database;
    await db.delete('transactions');
    await db.delete('accounts');
    await db.delete('categories');
    await db.delete('debts');
    await db.delete('recurring_transactions');
    await db.delete('budgets');
  });

  test('CSV correctness with quotes, commas, newlines, and UTF-8', () async {
    final path = await getDatabasesPath();
    await databaseFactory.deleteDatabase('\$path/cashio.db');
    dbHelper = DatabaseHelper.instance;
    csvService = SqfliteCsvExportService(dbHelper);
    accountRepo = SqfliteAccountRepository(dbHelper);
    txRepo = SqfliteTransactionRepository(dbHelper);

    final db = await dbHelper.database;
    await db.delete('transactions');
    await db.delete('accounts');
    await db.delete('categories');
    await db.delete('debts');
    await db.delete('recurring_transactions');
    await db.delete('budgets');

    final acc = Account(
      id: 'acc_csv_test',
      name: 'Main',
      currency: Currency.usd,
      initialBalance: 0,
      currentBalance: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await accountRepo.createAccount(acc);

    await txRepo.createTransaction(
      app_tx.Transaction(
        id: 'tx1',
        accountId: 'acc_csv_test',
        type: app_tx.TransactionType.income,
        amount: 1500,
        currency: Currency.usd,
        date: DateTime(2026, 1, 1),
        note: 'Hello, world',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    await txRepo.createTransaction(
      app_tx.Transaction(
        id: 'tx2',
        accountId: 'acc_csv_test',
        type: app_tx.TransactionType.expense,
        amount: 200,
        currency: Currency.usd,
        date: DateTime(2026, 1, 2),
        note: 'He said "hello"',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    await txRepo.createTransaction(
      app_tx.Transaction(
        id: 'tx3',
        accountId: 'acc_csv_test',
        type: app_tx.TransactionType.expense,
        amount: 300,
        currency: Currency.usd,
        date: DateTime(2026, 1, 3),
        note: 'Line one\nLine two',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    await txRepo.createTransaction(
      app_tx.Transaction(
        id: 'tx4',
        accountId: 'acc_csv_test',
        type: app_tx.TransactionType.expense,
        amount: 400,
        currency: Currency.usd,
        date: DateTime(2026, 1, 4),
        note: '\u062E\u0631\u06CC\u062F \u0633\u0648\u067E\u0631\u0645\u0627\u0631\u06A9\u062A',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await txRepo.createTransaction(
      app_tx.Transaction(
        id: 'tx5',
        accountId: 'acc_csv_test',
        type: app_tx.TransactionType.income,
        amount: 500,
        currency: Currency.usd,
        date: DateTime(2026, 1, 5),
        note: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final csv = await csvService.exportTransactionsToCsv();

    expect(csv, contains('"Hello, world"')); // Escaped comma
    expect(csv, contains('"He said ""hello"""')); // Escaped quotes
    expect(csv, contains('"Line one\nLine two"')); // Escaped newline
    expect(csv, contains('1500,USD,Main')); // Int amount and currency separate
    expect(
      csv,
      contains(
        '\u062E\u0631\u06CC\u062F \u0633\u0648\u067E\u0631\u0645\u0627\u0631\u06A9\u062A',
      ),
    ); // Persian
    expect(csv, contains('income,500,USD')); // empty fields handle cleanly
  });
}
