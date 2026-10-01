import 'package:uuid/uuid.dart';

import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import '../repositories/recurring_transaction_repository.dart';
import '../repositories/transaction_repository.dart';

class ProcessRecurringTransactions {
  final RecurringTransactionRepository _recurringRepo;
  final TransactionRepository _transactionRepo;

  ProcessRecurringTransactions(this._recurringRepo, this._transactionRepo);

  Future<void> execute() async {
    final activeRules = await _recurringRepo.getActiveRecurringTransactions();
    final now = DateTime.now();
    // Use start of today for comparisons to avoid time-of-day edge cases
    final today = DateTime(now.year, now.month, now.day);

    for (final rule in activeRules) {
      DateTime currentOccurrence = DateTime(
        rule.nextOccurrence.year,
        rule.nextOccurrence.month,
        rule.nextOccurrence.day,
      );

      bool updated = false;

      // Loop to catch up on missed occurrences up to today.
      // If nextOccurrence is tomorrow, this loop won't run.
      while (!currentOccurrence.isAfter(today)) {
        // Stop if we passed the rule's end date
        if (rule.endDate != null) {
          final end = DateTime(
            rule.endDate!.year,
            rule.endDate!.month,
            rule.endDate!.day,
          );
          if (currentOccurrence.isAfter(end)) break;
        }

        // Generate the transaction for this occurrence
        final tx = Transaction(
          id: const Uuid().v4(),
          accountId: rule.accountId,
          type: rule.type,
          amount: rule.amount,
          currency: rule.currency,
          categoryId: rule.categoryId,
          recurringId: rule.id,
          date: currentOccurrence, // preserve the original scheduled date
          note: rule.note,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _transactionRepo.createTransaction(tx);
        updated = true;

        // Advance to the next occurrence safely
        currentOccurrence = _calculateNextDate(
          currentOccurrence,
          rule.rule,
          rule.startDate.day,
        );
      }

      if (updated) {
        // Save the updated next_occurrence
        final updatedRule = rule.copyWith(
          nextOccurrence: currentOccurrence,
          updatedAt: DateTime.now(),
        );
        await _recurringRepo.updateRecurringTransaction(updatedRule);
      }
    }
  }

  DateTime _calculateNextDate(
    DateTime current,
    RecurrenceRule rule,
    int originalDay,
  ) {
    switch (rule) {
      case RecurrenceRule.daily:
        return current.add(const Duration(days: 1));
      case RecurrenceRule.weekly:
        return current.add(const Duration(days: 7));
      case RecurrenceRule.monthly:
        // Handle month-end logic correctly
        int nextMonth = current.month + 1;
        int nextYear = current.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        return _safeDate(nextYear, nextMonth, originalDay);
      case RecurrenceRule.yearly:
        return _safeDate(current.year + 1, current.month, originalDay);
    }
  }

  DateTime _safeDate(int year, int month, int desiredDay) {
    // If the month doesn't have the desired day (e.g. Feb 31), cap to the last valid day
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = desiredDay > lastDayOfMonth ? lastDayOfMonth : desiredDay;
    return DateTime(year, month, day);
  }
}
