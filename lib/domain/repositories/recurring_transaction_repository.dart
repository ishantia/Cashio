import '../models/recurring_transaction.dart';

abstract class RecurringTransactionRepository {
  Future<List<RecurringTransaction>> getAllRecurringTransactions();
  Future<List<RecurringTransaction>> getActiveRecurringTransactions();
  Future<RecurringTransaction?> getRecurringTransactionById(String id);
  Future<void> createRecurringTransaction(
    RecurringTransaction recurringTransaction,
  );
  Future<void> updateRecurringTransaction(
    RecurringTransaction recurringTransaction,
  );
  Future<void> deleteRecurringTransaction(String id);
}
