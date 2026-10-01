import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/category.dart';

import 'package:uuid/uuid.dart';

import 'budgets_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../core/utils/money_formatter.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  final Budget? existingBudget;
  const AddBudgetDialog({super.key, this.existingBudget});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  late TextEditingController amountController;
  late Currency selectedCurrency;
  late BudgetPeriod selectedPeriod;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: widget.existingBudget?.amount.toString() ?? '',
    );
    selectedCurrency = widget.existingBudget?.currency ?? Currency.usd;
    selectedPeriod = widget.existingBudget?.period ?? BudgetPeriod.monthly;
    selectedCategoryId = widget.existingBudget?.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref
        .watch(categoryRepositoryProvider)
        .getAllCategories();

    return AlertDialog(
      title: Text(
        widget.existingBudget == null
            ? AppLocalizations.of(context)!.addBudget
            : 'Edit Budget',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amount,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [MoneyInputFormatter()],
            ),
            DropdownButton<Currency>(
              value: selectedCurrency,
              items: Currency.defaultCurrencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.code)))
                  .toList(),
              onChanged: (c) => setState(() => selectedCurrency = c!),
            ),
            DropdownButton<BudgetPeriod>(
              value: selectedPeriod,
              items: BudgetPeriod.values
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (p) => setState(() => selectedPeriod = p!),
            ),
            FutureBuilder<List<Category>>(
              future: categoriesAsync,
              builder: (ctx, snapshot) {
                final cats = snapshot.data ?? [];
                return DropdownButton<String?>(
                  value: selectedCategoryId,
                  hint: Text(AppLocalizations.of(context)!.globalAllCategories),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        AppLocalizations.of(context)!.globalAllCategories,
                      ),
                    ),
                    ...cats.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (val) => setState(() => selectedCategoryId = val),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () async {
            final amt = MoneyInputFormatter.parseInt(amountController.text);
            if (amt <= 0) return;

            final budget = Budget(
              id: widget.existingBudget?.id ?? const Uuid().v4(),
              categoryId: selectedCategoryId,
              amount: amt,
              currency: selectedCurrency,
              period: selectedPeriod,
              isActive: widget.existingBudget?.isActive ?? true,
              createdAt: widget.existingBudget?.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
            );

            if (widget.existingBudget == null) {
              await ref.read(budgetRepositoryProvider).createBudget(budget);
            } else {
              await ref.read(budgetRepositoryProvider).updateBudget(budget);
            }
            ref.invalidate(allBudgetsProvider);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
