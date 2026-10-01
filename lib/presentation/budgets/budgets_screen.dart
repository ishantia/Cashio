import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/transaction.dart';
import '../../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/amount_display.dart';
import '../core/widgets/empty_state.dart';
import 'add_budget_dialog.dart';

final allBudgetsProvider = FutureProvider((ref) async {
  return ref.watch(budgetRepositoryProvider).getAllBudgets();
});

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final budgetsFuture = ref.watch(allBudgetsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.budgets)),
      body: budgetsFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (budgets) {
          if (budgets.isEmpty) {
            return EmptyState(
              icon: Icons.pie_chart_outline,
              title: 'No Budgets',
              message: 'Set spending limits to stay on top of your finances.',
              actionLabel: 'Create Budget',
              onAction: () => _showAddBudgetDialog(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allBudgetsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                return _BudgetCard(budget: budgets[index], ref: ref);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBudgetDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addBudget),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => const AddBudgetDialog(),
    ).then((_) => ref.invalidate(allBudgetsProvider));
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final WidgetRef ref;

  const _BudgetCard({required this.budget, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // We need to calculate how much has been spent.
    // In the old code it was fetching transactions. Let's do it cleanly using the transaction repository.
    final txRepo = ref.watch(transactionRepositoryProvider);

    // Compute current period start/end based on budget.period
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    if (budget.period == BudgetPeriod.monthly) {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    } else if (budget.period == BudgetPeriod.yearly) {
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31, 23, 59, 59);
    } else {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }

    return FutureBuilder(
      future: txRepo.searchTransactions(
        startDate: start,
        endDate: end,
        categoryId: budget.categoryId,
        currencyCode: budget.currency.code,
      ),
      builder: (context, snapshot) {
        int spent = 0;
        if (snapshot.hasData) {
          spent = snapshot.data!.fold(0, (sum, tx) {
            if (tx.type == TransactionType.expense) return sum + tx.amount;
            return sum;
          });
        }

        final double progress = budget.amount > 0
            ? (spent / budget.amount)
            : 0.0;
        final bool isOver = spent > budget.amount;
        final int remaining = budget.amount - spent;
        final double safeProgress = progress > 1.0 ? 1.0 : progress;

        Color progressColor = AppTheme.success;
        if (progress > 0.9) {
          progressColor = AppTheme.error;
        } else if (progress > 0.75)
          progressColor = Colors.orange;

        return AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Opacity(
            opacity: budget.isActive ? 1.0 : 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      budget.categoryId != null
                          ? 'Category Budget'
                          : 'Global Budget',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        if (!budget.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.disabled,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    AddBudgetDialog(existingBudget: budget),
                              ).then((_) => ref.invalidate(allBudgetsProvider));
                            } else if (value == 'toggle') {
                              await ref
                                  .read(budgetRepositoryProvider)
                                  .updateBudget(
                                    budget.copyWith(isActive: !budget.isActive),
                                  );
                              ref.invalidate(allBudgetsProvider);
                            } else if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.deleteBudget),
                                  content: Text(
                                    l10n.deleteBudgetConfirm,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(l10n.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(
                                        l10n.delete,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref
                                    .read(budgetRepositoryProvider)
                                    .deleteBudget(budget.id);
                                ref.invalidate(allBudgetsProvider);
                              }
                            }
                          },
                          itemBuilder: (BuildContext context) => [
    final l10n = AppLocalizations.of(context)!;
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(l10n.edit),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Text(
                                budget.isActive ? 'Disable' : 'Enable',
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                l10n.delete,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.spent,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AmountDisplay(
                          amount: spent,
                          currencyCode: budget.currency.code,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: isOver ? AppTheme.error : null,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isOver ? 'Overspent' : 'Remaining',
                          style: TextStyle(
                            color: isOver
                                ? AppTheme.error
                                : AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AmountDisplay(
                          amount: remaining.abs(),
                          currencyCode: budget.currency.code,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isOver
                                ? AppTheme.error
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: safeProgress,
                    backgroundColor: Colors.grey.shade200,
                    color: progressColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                    Text(
                      l10n.ofText,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
