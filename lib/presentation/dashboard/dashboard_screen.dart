import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cashio/l10n/generated/app_localizations.dart';

import '../../core/providers.dart';
import '../providers/data_providers.dart';
import '../../domain/models/category.dart';
import '../../domain/models/transaction.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/amount_display.dart';
import '../core/widgets/empty_state.dart';
import 'dashboard_provider.dart';
import '../transactions/add_transaction_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appInitProvider);
    final l10n = AppLocalizations.of(context)!;
    final dashboardData = ref.watch(dashboardStatsProvider);
    final accountsData = ref.watch(accountsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(
              '/more/settings',
            ), // Quick profile/settings shortcut
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionBottomSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.add),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(accountsListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: [
            _buildPeriodSelector(context, ref),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Balances
                  Text(
                    l10n.netWorth,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  _buildBalances(context, accountsData),
                  const SizedBox(height: 24),

                  // Summary (Income/Expense/Net)
                  dashboardData.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (data) => _buildFinancialSummary(context, data),
                  ),

                  const SizedBox(height: 24),

                  // Charts
                  dashboardData.when(
                    loading: () => const SizedBox(),
                    error: (_, _) => const SizedBox(),
                    data: (data) => _buildCharts(context, ref, data),
                  ),

                  const SizedBox(height: 24),

                  // Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.recentTransactions,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => context.go('/transactions'),
                        child: Text(l10n.seeAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  dashboardData.when(
                    loading: () => const SizedBox(),
                    error: (_, _) => const SizedBox(),
                    data: (data) => _buildRecentTransactions(
                      context,
                      data['recent'] as List<Transaction>,
                    ),
                  ),
                  const SizedBox(height: 80), // FAB padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, WidgetRef ref) {
    final period = ref.watch(dashboardPeriodProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: DashboardPeriod.values.map((p) {
          final isSelected = p == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(_getPeriodName(p)),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  ref.read(dashboardPeriodProvider.notifier).setPeriod(p);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppTheme.borderColor,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPeriodName(DashboardPeriod period) {
    switch (period) {
      case DashboardPeriod.today:
        return 'Today';
      case DashboardPeriod.thisWeek:
        return 'This Week';
      case DashboardPeriod.thisMonth:
        return 'This Month';
      case DashboardPeriod.thisYear:
        return 'This Year';
      case DashboardPeriod.custom:
        return 'Custom';
    }
  }

  Widget _buildBalances(BuildContext context, AsyncValue accountsData) {
    final l10n = AppLocalizations.of(context)!;
    return accountsData.when(
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Text(l10n.errorLoadingAccounts),
      data: (accounts) {
        if (accounts.isEmpty) {
          return Text(l10n.noAccountsSetUp);
        }

        final balancesByCurrency = <String, int>{};
        for (var acc in accounts) {
          final int existing = balancesByCurrency[acc.currency.code] ?? 0;
          balancesByCurrency[acc.currency.code] =
              (existing + acc.currentBalance).toInt();
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: balancesByCurrency.entries.map((e) {
            return AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AmountDisplay(
                    amount: e.value,
                    currencyCode: e.key,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.key,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFinancialSummary(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final incomeMap = data['income'] as Map<String, int>;
    final expenseMap = data['expense'] as Map<String, int>;

    // For simplicity in the dashboard summary, we might just show one currency or multiple rows.
    // Let's create a summary list by currency.
    final currencies = {...incomeMap.keys, ...expenseMap.keys};

    if (currencies.isEmpty) {
      return AppCard(
        child: EmptyState(
          icon: Icons.analytics_outlined,
          title: 'No Activity',
          message: 'No transactions in this period.',
        ),
      );
    }

    return Column(
      children: currencies.map((curr) {
        final inc = incomeMap[curr] ?? 0;
        final exp = expenseMap[curr] ?? 0;
        final net = inc - exp;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cash Flow ($curr)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    AmountDisplay(
                      amount: net,
                      currencyCode: curr,
                      forceSign: true,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                color: AppTheme.success,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.income,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AmountDisplay(
                            amount: inc,
                            currencyCode: curr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: AppTheme.borderColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: AppTheme.error,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.expenses,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AmountDisplay(
                            amount: exp,
                            currencyCode: curr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCharts(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final categorySpending =
        data['category_spending'] as Map<String, Map<String, int>>;
    if (categorySpending.isEmpty) return const SizedBox();

    final primaryCurr = categorySpending.keys.first;
    final spending = categorySpending[primaryCurr]!;

    if (spending.isEmpty) return const SizedBox();

    final categoriesAsync = ref.watch(categoriesListProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Spending ($primaryCurr)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 24),
          categoriesAsync.when(
            data: (categories) {
              return Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: spending.entries.map((e) {
                          final cat = categories.cast<Category?>().firstWhere(
                            (c) => c!.id == e.key,
                            orElse: () => null,
                          );
                          final color = cat != null && cat.color != null
                              ? Color(cat.color!)
                              : Colors.grey;
                          return PieChartSectionData(
                            value: e.value.toDouble(),
                            title: '',
                            color: color,
                            radius: 20,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: spending.entries.map((e) {
                      final cat = categories.cast<Category?>().firstWhere(
                        (c) => c!.id == e.key,
                        orElse: () => null,
                      );
                      final name = cat?.name ?? 'Uncategorized';
                      final color = cat != null && cat.color != null
                          ? Color(cat.color!)
                          : Colors.grey;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Vazirmatn',
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, s) => Text(l10n.error),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    List<Transaction> recent,
  ) {
    if (recent.isEmpty) {
      return AppCard(
        child: EmptyState(
          icon: Icons.receipt_long,
          title: 'No transactions',
          message: 'Start tracking by adding your first transaction.',
        ),
      );
    }

    return Column(
      children: recent.map((tx) {
        return _buildTransactionTile(context, tx);
      }).toList(),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Transaction tx) {
    final l10n = AppLocalizations.of(context)!;
    final isIncome = tx.type == TransactionType.income;
    final isTransfer =
        tx.type == TransactionType.transferOut ||
        tx.type == TransactionType.transferIn;

    IconData icon;
    Color iconColor;
    if (isTransfer) {
      icon = Icons.swap_horiz;
      iconColor = Colors.blue;
    } else if (isIncome) {
      icon = Icons.arrow_downward;
      iconColor = AppTheme.success;
    } else {
      icon = Icons.arrow_upward;
      iconColor = AppTheme.error;
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTransfer
                      ? l10n.transfer
                      : (tx.note?.isNotEmpty == true
                            ? tx.note!
                            : tx.type.name.toUpperCase()),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd().format(tx.date),
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          AmountDisplay(
            amount: tx.amount,
            currencyCode: tx.currency.code,
            type: tx.type, forceSign: !isTransfer,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddTransactionSheet();
      },
    );
  }
}
