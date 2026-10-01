import '../models/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<List<Transaction>> getTransactionsByAccountId(String accountId);
  Future<List<Transaction>> getTransactionsByDebtId(String debtId);
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );

  Future<List<Transaction>> searchTransactions({
    String? query,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    String? currencyCode,
    DateTime? startDate,
    DateTime? endDate,
    int? minAmount,
    int? maxAmount,
    bool? isDebtLinked,
    bool? isRecurringGenerated,
  });

  Future<Transaction?> getTransactionById(String id);

  /// Standard CRUD for Income/Expense
  Future<void> createTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);

  /// Transfer specifically handles two linked transactions
  Future<void> createTransfer({
    required Transaction transferOut,
    required Transaction transferIn,
  });

  Future<void> deleteTransfer(String transferId);

  // Dashboard Aggregations (returns grouped by currency)
  Future<Map<String, int>> getTotalIncomeByCurrency(
    DateTime start,
    DateTime end,
  );
  Future<Map<String, int>> getTotalExpenseByCurrency(
    DateTime start,
    DateTime end,
  );
  Future<Map<String, int>> getSpendingByCategory(
    String categoryId,
    DateTime start,
    DateTime end,
  );
}
