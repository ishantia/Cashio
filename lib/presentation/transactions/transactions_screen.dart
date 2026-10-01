import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../domain/models/transaction.dart' as app_tx;
import '../../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/amount_display.dart';
import '../core/widgets/empty_state.dart';
import 'add_transaction_sheet.dart';

final allTransactionsProvider = FutureProvider((ref) async {
  final txs = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();
  txs.sort((a, b) => b.date.compareTo(a.date)); // descending
  return txs;
});

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final txsFuture = ref.watch(allTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionsLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/more/search'),
          ),
        ],
      ),
      body: txsFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (txs) {
          if (txs.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No Transactions',
              message: 'You have not added any transactions yet.',
              actionLabel: 'Add Transaction',
              onAction: () => _showAddTransactionBottomSheet(context, ref),
            );
          }

          final grouped = _groupByDate(txs);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allTransactionsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final dateGroup = grouped.keys.elementAt(index);
                final dayTxs = grouped[dateGroup]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 8,
                      ),
                      child: Text(
                        _formatDateGroup(dateGroup),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...dayTxs.map(
                      (tx) => _buildTransactionTile(context, ref, tx),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionBottomSheet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.add),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Map<DateTime, List<app_tx.Transaction>> _groupByDate(
    List<app_tx.Transaction> txs,
  ) {
    final map = <DateTime, List<app_tx.Transaction>>{};
    for (var tx in txs) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      map.putIfAbsent(date, () => []).add(tx);
    }
    return map;
  }

  String _formatDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat.yMMMMEEEEd().format(date);
  }

  Widget _buildTransactionTile(
    BuildContext context,
    WidgetRef ref,
    app_tx.Transaction tx,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isIncome = tx.type == app_tx.TransactionType.income;
    final isTransfer =
        tx.type == app_tx.TransactionType.transferOut ||
        tx.type == app_tx.TransactionType.transferIn;

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

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppTheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteTransaction),
            content: Text(
              l10n.deleteTransactionConfirm,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  l10n.delete,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        final repo = ref.read(transactionRepositoryProvider);
        if (isTransfer && tx.transferId != null) {
          await repo.deleteTransfer(tx.transferId!);
        } else {
          await repo.deleteTransaction(tx.id);
        }
        ref.invalidate(allTransactionsProvider);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.transactionDeleted)));
      },
      child: AppCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        onTap: () {
          // Future: Edit / view details
        },
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // We can display category/account names here if we have a provider that joins them
                      // Or just rely on visual indicators for now.
                      if (tx.debtId != null)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.money_off,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      if (tx.recurringId != null)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.repeat,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          tx.note ?? 'No details',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AmountDisplay(
              amount: tx.amount,
              currencyCode: tx.currency.code,
              type: tx.type,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddTransactionSheet();
      },
    ).then((_) => ref.invalidate(allTransactionsProvider));
  }
}
