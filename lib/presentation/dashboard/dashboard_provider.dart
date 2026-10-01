import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/transaction.dart';

enum DashboardPeriod { today, thisWeek, thisMonth, thisYear, custom }

final dashboardPeriodProvider =
    NotifierProvider<DashboardPeriodNotifier, DashboardPeriod>(
      DashboardPeriodNotifier.new,
    );

class DashboardPeriodNotifier extends Notifier<DashboardPeriod> {
  @override
  DashboardPeriod build() => DashboardPeriod.thisMonth;
  void setPeriod(DashboardPeriod period) => state = period;
}

final customDateRangeProvider =
    NotifierProvider<CustomDateRangeNotifier, DateTimeRange?>(
      CustomDateRangeNotifier.new,
    );

class CustomDateRangeNotifier extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;
  void setRange(DateTimeRange? range) => state = range;
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  DateTimeRange(this.start, this.end);
}

final dashboardDateRangeProvider = Provider<DateTimeRange>((ref) {
  final period = ref.watch(dashboardPeriodProvider);
  final now = DateTime.now();

  switch (period) {
    case DashboardPeriod.today:
      return DateTimeRange(
        DateTime(now.year, now.month, now.day),
        DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    case DashboardPeriod.thisWeek:
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      return DateTimeRange(
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    case DashboardPeriod.thisMonth:
      return DateTimeRange(
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      );
    case DashboardPeriod.thisYear:
      return DateTimeRange(
        DateTime(now.year, 1, 1),
        DateTime(now.year, 12, 31, 23, 59, 59),
      );
    case DashboardPeriod.custom:
      final custom = ref.watch(customDateRangeProvider);
      if (custom != null) return custom;
      return DateTimeRange(
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      );
  }
  return DateTimeRange(
    DateTime(now.year, now.month, 1),
    DateTime(now.year, now.month + 1, 0, 23, 59, 59),
  );
});

final dashboardStatsProvider = FutureProvider((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final range = ref.watch(dashboardDateRangeProvider);

  // Total Income and Expense by currency
  final incomeMap = await repo.getTotalIncomeByCurrency(range.start, range.end);
  final expenseMap = await repo.getTotalExpenseByCurrency(
    range.start,
    range.end,
  );

  // Recent transactions
  // We should ideally have a method in repo: getTransactionsByDateRange
  // For now, using getAllTransactions and filtering, but we'll optimize by modifying the repo later if needed.
  // Actually, there is an existing search function we can use.
  final allTx = await repo.searchTransactions(
    startDate: range.start,
    endDate: range.end,
  );

  // Group spending by category
  final categoryExpenseMap =
      <String, Map<String, int>>{}; // Currency -> CategoryID -> Amount
  for (var tx in allTx) {
    if (tx.type == TransactionType.expense && tx.categoryId != null) {
      categoryExpenseMap.putIfAbsent(tx.currency.code, () => {});
      categoryExpenseMap[tx.currency.code]![tx.categoryId!] =
          (categoryExpenseMap[tx.currency.code]![tx.categoryId!] ?? 0) +
          tx.amount;
    }
  }

  // Get only top 5 recent transactions
  final recent = allTx.toList()..sort((a, b) => b.date.compareTo(a.date));
  final recent5 = recent.take(5).toList();

  return {
    'income': incomeMap,
    'expense': expenseMap,
    'recent': recent5,
    'category_spending': categoryExpenseMap,
    'transactions': allTx, // For charts
  };
});
