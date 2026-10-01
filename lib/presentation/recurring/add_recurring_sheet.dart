import '../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/recurring_transaction.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/currency.dart';
import '../../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/money_formatter.dart';

class AddRecurringSheet extends StatefulWidget {
  final WidgetRef ref;

  const AddRecurringSheet({super.key, required this.ref});

  @override
  State<AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends State<AddRecurringSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  Currency _selectedCurrency = Currency.usd;
  TransactionType _type = TransactionType.expense;
  RecurrenceRule _rule = RecurrenceRule.monthly;
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
              l10n.addRecurringTransaction,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: Text(
                      l10n.expense,
                      style: TextStyle(fontSize: 14),
                    ),
                    value: TransactionType.expense,
                    groupValue: _type,
                    onChanged: (val) => setState(() => _type = val!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: Text(l10n.income, style: TextStyle(fontSize: 14)),
                    value: TransactionType.income,
                    groupValue: _type,
                    onChanged: (val) => setState(() => _type = val!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.amount,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [MoneyInputFormatter()],
                        decoration: const InputDecoration(hintText: '0'),
                        autofocus: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.currency,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      InputDecorator(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: DropdownButton<Currency>(
                          value: _selectedCurrency,
                          isExpanded: true,
                          underline: SizedBox(),
                          items: Currency.defaultCurrencies.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c.code),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCurrency = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.repeats,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      InputDecorator(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: DropdownButton<RecurrenceRule>(
                          value: _rule,
                          isExpanded: true,
                          underline: SizedBox(),
                          items: RecurrenceRule.values.map((r) {
                            return DropdownMenuItem(
                              value: r,
                              child: Text(r.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _rule = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.startDate,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) setState(() => _startDate = date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Text(
              l10n.noteTitle,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: l10n.egNetflix,
              ),
            ),

            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(l10n.saveRule),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _save() async {
    final amount = MoneyInputFormatter.parseInt(_amountController.text);
    if (amount <= 0) return;

    final accounts = await widget.ref
        .read(accountRepositoryProvider)
        .getAllAccounts();
    if (accounts.isEmpty) return;
    final defaultAccount = accounts.first;

    final rule = RecurringTransaction(
      id: const Uuid().v4(),
      accountId: defaultAccount.id,
      categoryId: null,
      amount: amount,
      currency: _selectedCurrency,
      type: _type,
      rule: _rule,
      startDate: _startDate,
      nextOccurrence: _startDate,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await widget.ref
        .read(recurringTransactionRepositoryProvider)
        .createRecurringTransaction(rule);

    if (mounted) Navigator.pop(context);
  }
}
