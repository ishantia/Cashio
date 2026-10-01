import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cashio/data/database/database_helper.dart';
import 'package:cashio/data/repositories/sqflite_account_repository.dart';
import 'package:cashio/data/repositories/sqflite_transaction_repository.dart';
import 'package:cashio/data/repositories/sqflite_debt_repository.dart';
import 'package:cashio/data/repositories/sqflite_recurring_repository.dart';
import 'package:cashio/domain/models/account.dart';
import 'package:cashio/domain/models/currency.dart';
import 'package:cashio/domain/models/debt.dart';
import 'package:cashio/domain/models/recurring_transaction.dart';
import 'package:cashio/domain/models/transaction.dart' as app_tx;
import 'package:cashio/domain/usecases/calculate_debt_balance.dart';
import 'package:cashio/domain/usecases/process_recurring_transactions.dart';

void main() {
  late DatabaseHelper dbHelper;
  late SqfliteAccountRepository accountRepo;
  late SqfliteTransactionRepository txRepo;
  late SqfliteDebtRepository debtRepo;
  late SqfliteRecurringTransactionRepository recurringRepo;

  late CalculateDebtBalance calcDebtBalance;
  late ProcessRecurringTransactions processRecurring;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // removed;
    final path = await getDatabasesPath();
    // removed

    dbHelper = DatabaseHelper.instance;
    accountRepo = SqfliteAccountRepository(dbHelper);
    txRepo = SqfliteTransactionRepository(dbHelper);
    debtRepo = SqfliteDebtRepository(dbHelper);
    recurringRepo = SqfliteRecurringTransactionRepository(dbHelper);

    calcDebtBalance = CalculateDebtBalance(txRepo);
    processRecurring = ProcessRecurringTransactions(recurringRepo, txRepo);

    final db = await dbHelper.database;
    await db.delete('transactions');
    await db.delete('accounts');
    await db.delete('categories');
    await db.delete('debts');
    await db.delete('recurring_transactions');
    await db.delete('budgets');
  });

  test('Debt partial payments and multi-currency reduction', () async {
    // I owe John 100 USD
    final debt = Debt(
      id: 'debt_1',
      personName: 'John',
      direction: DebtDirection.iOwe,
      amount: 100,
      currency: Currency.usd,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await debtRepo.createDebt(debt);

    // Initial debt balance should be 100
    expect(await calcDebtBalance.execute(debt), 100);

    // I pay John 20 USD from my USD Account
    await txRepo.createTransaction(
      app_tx.Transaction(
        id: 'tx_pay_1',
        accountId: 'acc_usd',
        type: app_tx.TransactionType.expense,
        amount: 20,
        currency: Currency.usd,
        debtId: debt.id,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    expect(await calcDebtBalance.execute(debt), 80);

    // Someone owes me 50,000 Toman
    final debt2 = Debt(
      id: 'debt_2',
      personName: 'Ali',
      direction: DebtDirection.owedToMe,
      amount: 50000,
      currency: Currency.toman,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await debtRepo.createDebt(debt2);
    expect(await calcDebtBalance.execute(debt2), 50000);

    // Ali pays me back 100,000 Rial (which is 10,000 Toman)
    // The transaction happens in Rial
    await txRepo.createTransaction(
      app_tx.Transaction(
        id: 'tx_pay_2',
        accountId: 'acc_irr',
        type: app_tx.TransactionType.income,
        amount: 100000,
        currency: Currency.irr,
        debtId: debt2.id,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // The remaining debt in Toman should be 50,000 - 10,000 = 40,000
    expect(await calcDebtBalance.execute(debt2), 40000);
  });

  test('Recurring Engine - Idempotency and missing days generation', () async {
    final account = Account(
      id: 'acc1',
      name: 'Cash',
      currency: Currency.usd,
      initialBalance: 0,
      currentBalance: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await accountRepo.createAccount(account);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Scheduled to start 3 days ago, daily recurrence
    final startDate = today.subtract(const Duration(days: 3));

    final rule = RecurringTransaction(
      id: 'rec_1',
      amount: 50,
      currency: Currency.usd,
      accountId: account.id,
      type: app_tx.TransactionType.expense,
      rule: RecurrenceRule.daily,
      startDate: startDate,
      nextOccurrence: startDate,
      createdAt: now,
      updatedAt: now,
    );
    await recurringRepo.createRecurringTransaction(rule);

    // Run engine
    await processRecurring.execute();

    // It should have generated 4 transactions (today - 3, today - 2, today - 1, today).
    final txs = await txRepo.getAllTransactions();
    final recurringTxs = txs.where((t) => t.recurringId == rule.id).toList();
    expect(recurringTxs.length, 4);

    // Check next_occurrence is now tomorrow
    final updatedRule = await recurringRepo.getRecurringTransactionById(
      rule.id,
    );
    expect(updatedRule!.nextOccurrence.isAfter(today), true);

    // Run engine AGAIN immediately (Idempotency check)
    await processRecurring.execute();
    final txsAfter = await txRepo.getAllTransactions();
    final recurringTxsAfter = txsAfter
        .where((t) => t.recurringId == rule.id)
        .toList();
    // Still 4! No duplicates
    expect(recurringTxsAfter.length, 4);
  });
}
