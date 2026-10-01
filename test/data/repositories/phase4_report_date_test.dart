import 'package:flutter_test/flutter_test.dart';
import 'package:cashio/domain/models/transaction.dart' as app_tx;
import 'package:cashio/domain/models/currency.dart';
import 'package:cashio/data/repositories/sqflite_transaction_repository.dart';
import 'package:cashio/data/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('transactions');
  });

  test(
    'Transaction search correctly filters by date range for reports',
    () async {
      final repo = SqfliteTransactionRepository(DatabaseHelper.instance);

      await repo.createTransaction(
        app_tx.Transaction(
          id: 'tx1',
          accountId: 'acc1',
          amount: 100,
          currency: const Currency(
            code: 'USD',
            name: 'US Dollar',
            symbol: '\$',
            fractionalDigits: 2,
          ),
          type: app_tx.TransactionType.expense,
          date: DateTime(2023, 5, 10),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await repo.createTransaction(
        app_tx.Transaction(
          id: 'tx2',
          accountId: 'acc1',
          amount: 200,
          currency: const Currency(
            code: 'USD',
            name: 'US Dollar',
            symbol: '\$',
            fractionalDigits: 2,
          ),
          type: app_tx.TransactionType.expense,
          date: DateTime(2023, 6, 15),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Filter for May
      final mayTxs = await repo.searchTransactions(
        startDate: DateTime(2023, 5, 1),
        endDate: DateTime(2023, 5, 31),
      );
      expect(mayTxs.length, 1);
      expect(mayTxs.first.id, 'tx1');

      // Filter for June
      final juneTxs = await repo.searchTransactions(
        startDate: DateTime(2023, 6, 1),
        endDate: DateTime(2023, 6, 30),
      );
      expect(juneTxs.length, 1);
      expect(juneTxs.first.id, 'tx2');
    },
  );
}
