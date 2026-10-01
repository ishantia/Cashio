import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/providers.dart';
import '../../domain/models/transaction.dart' as app_tx;
import '../../l10n/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/amount_display.dart';
import '../core/widgets/empty_state.dart';
import '../providers/data_providers.dart';


class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final txAsync = ref
        .watch(transactionRepositoryProvider)
        .searchTransactions(startDate: startDate, endDate: endDate);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final accountsAsync = ref.watch(accountsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports ?? 'Reports'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: DateTimeRange(start: startDate, end: endDate),
              );
              if (range != null) {
                setState(() {
                  startDate = range.start;
                  endDate = range.end;
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<app_tx.Transaction>>(
        future: txAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text(l10n.error));
          final txs = snapshot.data ?? [];
          if (txs.isEmpty) {
            return EmptyState(
              icon: Icons.bar_chart,
              title: l10n.noReportsYet,
              message: l10n.addTransactionsToSee,
            );
          }

          final incomeByCurrency = <String, int>{};
          final expenseByCurrency = <String, int>{};
          final expenseByCategory = <String, Map<String, int>>{};
          final expenseByAccount = <String, Map<String, int>>{};

          for (final tx in txs) {
            if (tx.type == app_tx.TransactionType.transferIn ||
                tx.type == app_tx.TransactionType.transferOut) {
              continue;
            }

            final code = tx.currency.code;

            if (tx.type == app_tx.TransactionType.income) {
              incomeByCurrency[code] =
                  (incomeByCurrency[code] ?? 0) + tx.amount;
            } else if (tx.type == app_tx.TransactionType.expense) {
              expenseByCurrency[code] =
                  (expenseByCurrency[code] ?? 0) + tx.amount;

              final cat = tx.categoryId ?? 'uncategorized';
              expenseByCategory.putIfAbsent(cat, () => {});
              expenseByCategory[cat]![code] =
                  (expenseByCategory[cat]![code] ?? 0) + tx.amount;

              final acc = tx.accountId;
              expenseByAccount.putIfAbsent(acc, () => {});
              expenseByAccount[acc]![code] =
                  (expenseByAccount[acc]![code] ?? 0) + tx.amount;
            }
          }

          final allCurrencies = incomeByCurrency.keys.toSet().union(
            expenseByCurrency.keys.toSet(),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date Range Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${startDate.toString().substring(0, 10)} - ${endDate.toString().substring(0, 10)}',
                    style: const TextStyle(fontFamily: 'Vazirmatn', 
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Cash Flow
              Text(
                l10n.cashFlow,
                style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              ...allCurrencies.map((code) {
                final inc = incomeByCurrency[code] ?? 0;
                final exp = expenseByCurrency[code] ?? 0;
                final net = inc - exp;
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.netFlow,
                              style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
                            ),
                            AmountDisplay(
                              amount: net,
                              currencyCode: code,
                              type: net >= 0
                                  ? app_tx.TransactionType.income
                                  : app_tx.TransactionType.expense,
                              forceSign: true,
                              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 18),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.income,
                              style: TextStyle(fontFamily: 'Vazirmatn', color: AppTheme.textSecondary),
                            ),
                            AmountDisplay(
                              amount: inc,
                              currencyCode: code,
                              type: app_tx.TransactionType.income,
                              forceSign: true,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.expense,
                              style: TextStyle(fontFamily: 'Vazirmatn', color: AppTheme.textSecondary),
                            ),
                            AmountDisplay(
                              amount: exp,
                              currencyCode: code,
                              type: app_tx.TransactionType.expense,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: 24),
              Text(
                l10n.spendingByCategory,
                style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              ...allCurrencies.map((code) {
                // Get all categories for this currency
                final catSpending = <String, int>{};
                for (final cat in expenseByCategory.keys) {
                  if (expenseByCategory[cat]!.containsKey(code)) {
                    catSpending[cat] = expenseByCategory[cat]![code]!;
                  }
                }

                if (catSpending.isEmpty) return SizedBox();

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          code,
                          style: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 24),
                        categoriesAsync.when(
                          data: (categories) {
                            return _buildCategoryChart(
                              catSpending,
                              categories,
                              code,
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (e, s) => Text(l10n.error),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChart(
    Map<String, int> spending,
    List<dynamic> categories,
    String currencyCode,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: spending.entries.map((e) {
                final cat = categories.firstWhere(
                  (c) => c.id == e.key,
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
        SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: spending.entries.map((e) {
            final cat = categories.firstWhere(
              (c) => c.id == e.key,
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
                SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontFamily: 'Vazirmatn'),
                ),
                SizedBox(width: 8),
                AmountDisplay(
                  amount: e.value,
                  currencyCode: currencyCode,
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
