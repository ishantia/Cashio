import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import 'package:cashio/data/database/database_helper.dart';
import 'package:cashio/data/repositories/sqflite_account_repository.dart';
import 'package:cashio/data/repositories/sqflite_transaction_repository.dart';
import 'package:cashio/domain/models/account.dart';
import 'package:cashio/domain/models/currency.dart';
import 'package:cashio/domain/models/transaction.dart' as app_tx;
import 'package:cashio/domain/usecases/calculate_account_balance.dart';

void main() {
  late DatabaseHelper dbHelper;
  late SqfliteAccountRepository accountRepo;
  late SqfliteTransactionRepository txRepo;
  late CalculateAccountBalance calculateBalance;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // For tests we want a fresh in-memory database each time.
    // DatabaseHelper is a singleton, so we trick it or just use inMemoryDatabasePath directly.
    // Since DatabaseHelper uses 'cashio.db', we can just use FFI's in-memory factory
    // Wait, FFI in-memory databases need to be opened via the factory explicitly.
    // We can delete the db file before each test.
    // removed

    // We will create an instance specifically for tests
    dbHelper = DatabaseHelper.instance;
    // We can't easily change the path in the singleton unless we expose a setter.
    // Let's just use FFI's default location and delete it.
    final path = await getDatabasesPath();
    // removed

    accountRepo = SqfliteAccountRepository(dbHelper);
    txRepo = SqfliteTransactionRepository(dbHelper);
    calculateBalance = CalculateAccountBalance(txRepo);

    final db = await dbHelper.database;
    await db.delete('transactions');
    await db.delete('accounts');
    await db.delete('categories');
    await db.delete('debts');
    await db.delete('recurring_transactions');
    await db.delete('budgets');
  });

  test('Financial engine integration test: balances, transfers, and aggregations', () async {
    // 1. Create Accounts
    final accUsd = Account(
      id: 'acc1',
      name: 'USD Wallet',
      currency: Currency.usd,
      initialBalance: 10000,
      currentBalance: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final accIrr = Account(
      id: 'acc2',
      name: 'Rial Bank',
      currency: Currency.irr,
      initialBalance: 500000,
      currentBalance: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final accToman = Account(
      id: 'acc3',
      name: 'Toman Cash',
      currency: Currency.toman,
      initialBalance: 20000,
      currentBalance: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await accountRepo.createAccount(accUsd);
    await accountRepo.createAccount(accIrr);
    await accountRepo.createAccount(accToman);

    // Initial Balances check
    expect(await calculateBalance.execute(accUsd), 10000);

    // 2. Add Income and Expense
    await txRepo.createTransaction(
      app_tx.Transaction(
        id: 'tx1',
        accountId: accUsd.id,
        type: app_tx.TransactionType.income,
        amount: 5000,
        currency: Currency.usd,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await txRepo.createTransaction(
      app_tx.Transaction(
        id: 'tx2',
        accountId: accUsd.id,
        type: app_tx.TransactionType.expense,
        amount: 2000,
        currency: Currency.usd,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    expect(
      await calculateBalance.execute(accUsd),
      13000,
    ); // 10000 + 5000 - 2000

    // 3. Same-currency transfer
    final transferId1 = const Uuid().v4();
    await txRepo.createTransfer(
      transferOut: app_tx.Transaction(
        id: 'tx3',
        accountId: accIrr.id,
        type: app_tx.TransactionType.transferOut,
        amount: 100000,
        currency: Currency.irr,
        transferId: transferId1,
        linkedTransactionId: 'tx4',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      transferIn: app_tx.Transaction(
        id: 'tx4',
        accountId: accIrr.id,
        type: app_tx.TransactionType.transferIn,
        amount: 100000,
        currency: Currency.irr,
        transferId: transferId1,
        linkedTransactionId: 'tx3',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    // Since it's transfer from IRR to IRR (maybe different accounts, here we accidentally transferred to same account for test logic, let's test net zero)
    expect(await calculateBalance.execute(accIrr), 500000);

    // 4. Rial <-> Toman transfer (Different currencies)
    // Transfer 10,000 Toman from Toman Cash to Rial Bank (equals 100,000 Rial)
    final transferId2 = const Uuid().v4();
    await txRepo.createTransfer(
      transferOut: app_tx.Transaction(
        id: 'tx5',
        accountId: accToman.id,
        type: app_tx.TransactionType.transferOut,
        amount: 10000,
        currency: Currency.toman,
        transferId: transferId2,
        linkedTransactionId: 'tx6',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      transferIn: app_tx.Transaction(
        id: 'tx6',
        accountId: accIrr.id,
        type: app_tx.TransactionType.transferIn,
        amount: 100000,
        currency: Currency.irr,
        transferId: transferId2,
        linkedTransactionId: 'tx5',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    expect(await calculateBalance.execute(accToman), 10000); // 20000 - 10000
    expect(await calculateBalance.execute(accIrr), 600000); // 500000 + 100000

    // 5. Aggregations (Transfers do not affect income/expense)
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final incomes = await txRepo.getTotalIncomeByCurrency(start, end);
    final expenses = await txRepo.getTotalExpenseByCurrency(start, end);

    expect(incomes['USD'], 5000); // Only tx1
    expect(
      incomes.containsKey('IRR'),
      false,
    ); // TransferIn should not be income
    expect(expenses['USD'], 2000); // Only tx2
    expect(
      expenses.containsKey('TOMAN'),
      false,
    ); // TransferOut should not be expense

    // 6. Deletion of transfer
    await txRepo.deleteTransfer(transferId2);
    expect(await calculateBalance.execute(accToman), 20000); // Back to 20k
    expect(await calculateBalance.execute(accIrr), 500000); // Back to 500k
  });
}
