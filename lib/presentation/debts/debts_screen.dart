import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../core/providers.dart';
import '../../domain/models/debt.dart';
import '../../domain/models/transaction.dart';

import 'package:uuid/uuid.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/amount_display.dart';
import '../core/widgets/empty_state.dart';
import '../core/utils/money_formatter.dart';
import 'add_debt_sheet.dart';

final allDebtsProvider = FutureProvider<List<Debt>>((ref) async {
  return ref.watch(debtRepositoryProvider).getAllDebts();
});

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final debtsAsync = ref.watch(allDebtsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debtsAndLoans)),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (debts) {
          if (debts.isEmpty) {
            return EmptyState(
              icon: Icons.handshake_outlined,
              title: 'No Debts',
              message: l10n.noDebtsRecorded,
              actionLabel: 'Record Debt',
              onAction: () => _showAddDebtDialog(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allDebtsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: debts.length,
              itemBuilder: (context, index) {
                return _DebtCard(debt: debts[index], ref: ref);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDebtDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Debt'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddDebtDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddDebtSheet(ref: ref),
    ).then((_) => ref.invalidate(allDebtsProvider));
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;
  final WidgetRef ref;

  const _DebtCard({required this.debt, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isIOwe = debt.direction == DebtDirection.iOwe;
    final l10n = AppLocalizations.of(context)!;
    final color = isIOwe ? AppTheme.error : AppTheme.success;

    // FutureBuilder to compute the exact remaining amount via transactions
    final calculateDebtBalance = ref.watch(calculateDebtBalanceProvider);

    return FutureBuilder<int>(
      future: calculateDebtBalance.execute(debt),
      builder: (context, snapshot) {
        final remaining = snapshot.data ?? debt.amount;
        final double progress = debt.amount > 0
            ? (debt.amount - remaining) / debt.amount
            : 0;
        final isPaidOff = remaining <= 0;

        return AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
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
                          color: isPaidOff
                              ? Colors.grey.shade200
                              : color.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isIOwe ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isPaidOff ? Colors.grey : color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.personName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            isIOwe ? 'You Owe' : 'Owes You',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Debt'),
                            content: const Text(
                              'Are you sure you want to delete this debt? Transactions linked to it will not be deleted, but the link will be lost.',
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
                              .read(debtRepositoryProvider)
                              .deleteDebt(debt.id);
                          ref.invalidate(allDebtsProvider);
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
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPaidOff ? 'Paid Off' : 'Remaining',
                        style: TextStyle(
                          color: isPaidOff
                              ? AppTheme.success
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: isPaidOff
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AmountDisplay(
                        amount: remaining > 0 ? remaining : 0,
                        currencyCode: debt.currency.code,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: isPaidOff ? AppTheme.success : color,
                        ),
                      ),
                    ],
                  ),
                  if (!isPaidOff)
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _DebtPaymentSheet(
                            ref: ref,
                            debt: debt,
                            remaining: remaining,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.payment, size: 16),
                      label: Text(isIOwe ? 'Pay' : 'Receive'),
                    ),
                ],
              ),

              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  color: isPaidOff ? AppTheme.success : color,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${NumberFormat.currency(symbol: debt.currency.symbol, decimalDigits: 0).format(debt.amount)}',
                  ),
                  if (debt.dueDate != null)
                    Text(
                      'Due: ${DateFormat.yMd().format(debt.dueDate!)}',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DebtPaymentSheet extends StatefulWidget {
  final WidgetRef ref;
  final Debt debt;
  final int remaining;

  const _DebtPaymentSheet({
    required this.ref,
    required this.debt,
    required this.remaining,
  });

  @override
  State<_DebtPaymentSheet> createState() => _DebtPaymentSheetState();
}

class _DebtPaymentSheetState extends State<_DebtPaymentSheet> {
  late TextEditingController _amountController;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.remaining.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isIOwe = widget.debt.direction == DebtDirection.iOwe;
    final color = isIOwe ? AppTheme.error : AppTheme.success;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomInset,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isIOwe ? 'Pay Debt' : 'Receive Payment',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),

            const Text('Amount', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [MoneyInputFormatter()],
              decoration: InputDecoration(
                suffixText: widget.debt.currency.code,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            const Text(
              'Note (Optional)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'e.g. Partial payment',
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color),
                onPressed: _save,
                child: Text(isIOwe ? 'Record Payment' : 'Record Receipt'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _save() async {
    final amount = MoneyInputFormatter.parseInt(_amountController.text);
    if (amount <= 0) return;

    // To properly record a debt payment, we just need a transaction.
    // We should also link it to an account, but for simplicity here we'll use a dummy/default account
    // or just pass 'cash' if we don't have account selection in this mini sheet.
    // Wait, the transaction requires an accountId!

    // We can fetch accounts and use the first one.
    final accounts = await widget.ref
        .read(accountRepositoryProvider)
        .getAllAccounts();
    if (accounts.isEmpty) return; // Edge case
    final defaultAccount = accounts.first;

    final isIOwe = widget.debt.direction == DebtDirection.iOwe;
    final tx = Transaction(
      id: const Uuid().v4(),
      accountId: defaultAccount.id,
      categoryId: null,
      amount: amount,
      currency: widget.debt.currency,
      type: isIOwe ? TransactionType.expense : TransactionType.income,
      date: DateTime.now(),
      note: _noteController.text.isEmpty
          ? 'Debt payment: ${widget.debt.personName}'
          : _noteController.text,
      debtId: widget.debt.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await widget.ref.read(transactionRepositoryProvider).createTransaction(tx);
    widget.ref.invalidate(allDebtsProvider);

    if (mounted) Navigator.pop(context);
  }
}
