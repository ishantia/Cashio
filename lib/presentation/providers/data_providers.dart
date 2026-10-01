import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/account.dart';

final accountsListProvider = FutureProvider<List<Account>>((ref) async {
  final repository = ref.watch(accountRepositoryProvider);
  final calculateBalance = ref.watch(calculateAccountBalanceProvider);

  final accounts = await repository.getAllAccounts();

  final updatedAccounts = <Account>[];
  for (final account in accounts) {
    final balance = await calculateBalance.execute(account);
    updatedAccounts.add(account.copyWith(currentBalance: balance));
  }

  return updatedAccounts;
});

final categoriesListProvider = FutureProvider((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getAllCategories();
});

final dashboardAggregationsProvider = FutureProvider((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final incomeMap = await repo.getTotalIncomeByCurrency(
    startOfMonth,
    endOfMonth,
  );
  final expenseMap = await repo.getTotalExpenseByCurrency(
    startOfMonth,
    endOfMonth,
  );

  // We could fetch recent transactions here too.
  final allTx = await repo.getAllTransactions();
  final recent = allTx.take(5).toList();

  return {'income': incomeMap, 'expense': expenseMap, 'recent': recent};
});
