import 'package:flutter_test/flutter_test.dart';
import 'package:cashio/domain/models/account.dart';
import 'package:cashio/domain/models/currency.dart';
import 'package:cashio/domain/models/transaction.dart' as app_tx;
import 'package:cashio/domain/repositories/transaction_repository.dart';
import 'package:cashio/domain/usecases/calculate_account_balance.dart';

class MockTransactionRepository implements TransactionRepository {
  List<app_tx.Transaction> transactions = [];

  @override
  Future<List<app_tx.Transaction>> getTransactionsByAccountId(
    String accountId,
  ) async {
    return transactions.where((tx) => tx.accountId == accountId).toList();
  }

  @override
  Future<List<app_tx.Transaction>> getTransactionsByDebtId(
    String debtId,
  ) async {
    return transactions.where((tx) => tx.debtId == debtId).toList();
  }

  @override
  Future<List<app_tx.Transaction>> searchTransactions({
    String? query,
    app_tx.TransactionType? type,
    String? accountId,
    String? categoryId,
    String? currencyCode,
    DateTime? startDate,
    DateTime? endDate,
    int? minAmount,
    int? maxAmount,
    bool? isDebtLinked,
    bool? isRecurringGenerated,
  }) async {
    return transactions;
  }

  @override
  Future<Map<String, int>> getTotalIncomeByCurrency(
    DateTime start,
    DateTime end,
  ) async => {};

  @override
  Future<Map<String, int>> getTotalExpenseByCurrency(
    DateTime start,
    DateTime end,
  ) async => {};

  @override
  Future<Map<String, int>> getSpendingByCategory(
    String currencyCode,
    DateTime start,
    DateTime end,
  ) async => {};

  @override
  Future<void> createTransaction(app_tx.Transaction transaction) async {}
  @override
  Future<void> createTransfer({
    required app_tx.Transaction transferOut,
    required app_tx.Transaction transferIn,
  }) async {}
  @override
  Future<void> deleteTransaction(String id) async {}
  @override
  Future<void> deleteTransfer(String transferId) async {}
  @override
  Future<List<app_tx.Transaction>> getAllTransactions() async => transactions;
  @override
  Future<List<app_tx.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async => [];
  @override
  Future<void> updateTransaction(app_tx.Transaction transaction) async {}
  @override
  Future<app_tx.Transaction?> getTransactionById(String id) async => null;
}

void main() {
  late MockTransactionRepository mockRepo;
  late CalculateAccountBalance usecase;

  setUp(() {
    mockRepo = MockTransactionRepository();
    usecase = CalculateAccountBalance(mockRepo);
  });

  test('Calculate balance includes initial, income, expense, and transfers correctly', () async {
    final account = Account(
      id: 'acc1',
      name: 'Cash',
      currency: Currency.usd,
      initialBalance: 5000, // 50.00
      currentBalance: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    mockRepo.transactions.addAll([
      app_tx.Transaction(
        id: '1',
        accountId: 'acc1',
        type: app_tx.TransactionType.income,
        amount: 2000,
        currency: Currency.usd,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      app_tx.Transaction(
        id: '2',
        accountId: 'acc1',
        type: app_tx.TransactionType.expense,
        amount: 1500,
        currency: Currency.usd,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      app_tx.Transaction(
        id: '3',
        accountId: 'acc1',
        type: app_tx.TransactionType.transferIn,
        amount: 1000,
        currency: Currency.usd,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      app_tx.Transaction(
        id: '4',
        accountId: 'acc1',
        type: app_tx.TransactionType.transferOut,
        amount: 500,
        currency: Currency.usd,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);

    final balance = await usecase.execute(account);
    // 5000 + 2000 - 1500 + 1000 - 500 = 6000
    expect(balance, equals(6000));
  });

  test('Calculate balance for Rial -> Toman transfer explicitly separates amounts', () async {
    final tomanAccount = Account(
      id: 'acc_toman',
      name: 'Toman Acc',
      currency: Currency.toman,
      initialBalance: 0,
      currentBalance: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Suppose we transferred 10,000 Rial to this Toman account.
    // The transaction for the destination account (Toman) is recorded in Toman!
    mockRepo.transactions.add(
      app_tx.Transaction(
        id: 'tx_in',
        accountId: 'acc_toman',
        type: app_tx.TransactionType.transferIn,
        amount: 1000, // 1000 Toman = 10,000 Rial
        currency: Currency.toman,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transferId: 'transfer_123',
      ),
    );

    final balance = await usecase.execute(tomanAccount);
    expect(balance, equals(1000)); // Exactly 1,000 Toman.
  });
}
