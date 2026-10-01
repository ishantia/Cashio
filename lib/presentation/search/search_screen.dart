import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/transaction.dart' as app_tx;
import '../../l10n/generated/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String? query;
  app_tx.TransactionType? type;
  DateTime? startDate;
  DateTime? endDate;
  String? accountId;
  String? categoryId;
  String? currencyCode;
  int? minAmount;
  int? maxAmount;
  bool? isDebtLinked;
  bool? isRecurringGenerated;

  void _showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Advanced Filters',
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Min Amount',
                            ),
                            onChanged: (val) {
                              minAmount = int.tryParse(val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max Amount',
                            ),
                            onChanged: (val) {
                              maxAmount = int.tryParse(val);
                            },
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.debtLinkedOnly),
                      value: isDebtLinked ?? false,
                      onChanged: (val) {
                        setModalState(() => isDebtLinked = val ? true : null);
                        setState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.recurringGeneratedOnly,
                      ),
                      value: isRecurringGenerated ?? false,
                      onChanged: (val) {
                        setModalState(
                          () => isRecurringGenerated = val ? true : null,
                        );
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      child: Text(AppLocalizations.of(context)!.apply),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final resultsAsync = ref
        .watch(transactionRepositoryProvider)
        .searchTransactions(
          query: query,
          type: type,
          startDate: startDate,
          endDate: endDate,
          accountId: accountId,
          categoryId: categoryId,
          currencyCode: currencyCode,
          minAmount: minAmount,
          maxAmount: maxAmount,
          isDebtLinked: isDebtLinked,
          isRecurringGenerated: isRecurringGenerated,
        );

    // For dropdowns, we can fetch accounts and categories
    // // final accountsAsync = ref.watch(accountsProvider);
    // Let's assume there's a categoryListProvider or similar

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showAdvancedFilters(context),
          ),
        ],
        title: TextField(
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchHint,
            border: InputBorder.none,
          ),
          onSubmitted: (val) {
            setState(() => query = val);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: Text(AppLocalizations.of(context)!.income),
                    backgroundColor: type == app_tx.TransactionType.income
                        ? Colors.green.shade100
                        : null,
                    onPressed: () =>
                        setState(() => type = app_tx.TransactionType.income),
                  ),
                  ActionChip(
                    label: Text(AppLocalizations.of(context)!.expense),
                    backgroundColor: type == app_tx.TransactionType.expense
                        ? Colors.red.shade100
                        : null,
                    onPressed: () =>
                        setState(() => type = app_tx.TransactionType.expense),
                  ),
                  ActionChip(
                    label: Text(
                      AppLocalizations.of(context)!.transfer ?? 'Transfer',
                    ),
                    backgroundColor: type == app_tx.TransactionType.transferOut
                        ? Colors.blue.shade100
                        : null,
                    onPressed: () => setState(
                      () => type = app_tx.TransactionType.transferOut,
                    ),
                  ),
                  ActionChip(
                    label: Text(
                      startDate != null
                          ? startDate.toString().substring(0, 10)
                          : 'Start Date',
                    ),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) setState(() => startDate = d);
                    },
                  ),
                  ActionChip(
                    label: Text(
                      endDate != null
                          ? endDate.toString().substring(0, 10)
                          : 'End Date',
                    ),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) setState(() => endDate = d);
                    },
                  ),
                  ActionChip(
                    label: Text(AppLocalizations.of(context)!.clearFilters),
                    onPressed: () => setState(() {
                      query = null;
                      type = null;
                      startDate = null;
                      endDate = null;
                      accountId = null;
                      categoryId = null;
                      currencyCode = null;
                    }),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<app_tx.Transaction>>(
              future: resultsAsync,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${AppLocalizations.of(context)!.error}: ${snapshot.error}',
                    ),
                  );
                }
                final txs = snapshot.data ?? [];
                if (txs.isEmpty)
                  return Center(
                    child: Text(AppLocalizations.of(context)!.noResults),
                  );

                return ListView.builder(
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    return ListTile(
                      title: Text(tx.note ?? tx.type.name.toUpperCase()),
                      subtitle: Text(tx.date.toString().substring(0, 10)),
                      trailing: Text("${tx.amount} ${tx.currency.code}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
