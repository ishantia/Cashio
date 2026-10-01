import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../core/providers.dart';
import '../../domain/models/recurring_transaction.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/amount_display.dart';
import '../core/widgets/empty_state.dart';
import 'add_recurring_sheet.dart';

final allRecurringProvider = FutureProvider<List<RecurringTransaction>>((
  ref,
) async {
  return ref
      .watch(recurringTransactionRepositoryProvider)
      .getAllRecurringTransactions();
});

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncData = ref.watch(allRecurringProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTransactions)),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (rules) {
          if (rules.isEmpty) {
            return EmptyState(
              icon: Icons.repeat,
              title: 'No Recurring Transactions',
              message: 'Automate your regular income and expenses.',
              actionLabel: 'Add Recurring',
              onAction: () => _showAddRecurringSheet(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allRecurringProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: rules.length,
              itemBuilder: (context, index) {
                return _RecurringCard(rule: rules[index], ref: ref);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecurringSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Recurring'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddRecurringSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddRecurringSheet(ref: ref),
    ).then((_) => ref.invalidate(allRecurringProvider));
  }
}

class _RecurringCard extends StatelessWidget {
  final RecurringTransaction rule;
  final WidgetRef ref;

  const _RecurringCard({required this.rule, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isIncome = rule.type.name == 'income';
    final color = isIncome ? AppTheme.success : AppTheme.error;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Opacity(
        opacity: rule.isActive ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: color,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rule.note ?? rule.type.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Repeats ${rule.rule.name.capitalize()}',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Switch(
                      value: rule.isActive,
                      activeColor: AppTheme.lightTheme.colorScheme.primary,
                      onChanged: (val) async {
                        await ref
                            .read(recurringTransactionRepositoryProvider)
                            .updateRecurringTransaction(
                              rule.copyWith(isActive: val),
                            );
                        ref.invalidate(allRecurringProvider);
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Recurring'),
                              content: const Text(
                                'Are you sure you want to delete this automation? Past transactions will remain.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref
                                .read(recurringTransactionRepositoryProvider)
                                .deleteRecurringTransaction(rule.id);
                            ref.invalidate(allRecurringProvider);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
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
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AmountDisplay(
                      amount: rule.amount,
                      currencyCode: rule.currency.code,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Next Date',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMd().format(rule.nextOccurrence),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
