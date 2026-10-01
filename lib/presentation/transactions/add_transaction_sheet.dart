import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/transaction.dart';
import '../../domain/models/account.dart';
import '../../domain/models/category.dart';
import '../../domain/models/currency.dart';
import '../../core/providers.dart';
import '../providers/data_providers.dart';
import '../dashboard/dashboard_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/money_formatter.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Theme.of(context).colorScheme.onSurface,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: const [
                    Tab(text: 'Expense'),
                    Tab(text: 'Income'),
                    Tab(text: 'Transfer'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TransactionForm(
                      type: TransactionType.expense,
                      scrollController: scrollController,
                    ),
                    _TransactionForm(
                      type: TransactionType.income,
                      scrollController: scrollController,
                    ),
                    _TransferForm(scrollController: scrollController),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TransactionForm extends ConsumerStatefulWidget {
  final TransactionType type;
  final ScrollController scrollController;

  const _TransactionForm({required this.type, required this.scrollController});

  @override
  ConsumerState<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<_TransactionForm> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  Account? _selectedAccount;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_selectedAccount == null || _amountController.text.isEmpty) return;

    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final repo = ref.read(transactionRepositoryProvider);

    // Using integer semantics! If the currency has fractional digits, multiply accordingly.
    // For MVP phase 6, assuming basic integer entry for IRR/Toman.
    // In a full solution, we'd adjust by `_selectedAccount!.currency.fractionalDigits`.
    final intAmount = amount.round();

    final tx = Transaction(
      id: const Uuid().v4(),
      accountId: _selectedAccount!.id,
      categoryId: _selectedCategory?.id,
      amount: intAmount,
      currency: _selectedAccount!.currency,
      date: _selectedDate,
      type: widget.type,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repo.createTransaction(tx);

    // Invalidate dashboard to reflect new balance
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(accountsListProvider);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Amount', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [MoneyInputFormatter()],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: widget.type == TransactionType.expense ? '- ' : '+ ',
            hintText: '0',
          ),
        ),
        const SizedBox(height: 16),

        const Text('Account', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        accountsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, s) => const Text('Error'),
          data: (accounts) => InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: DropdownButton<Account>(
              value: _selectedAccount,
              hint: const Text('Select Account'),
              isExpanded: true,
              underline: const SizedBox(),
              items: accounts
                  .map(
                    (a) => DropdownMenuItem(
                      value: a,
                      child: Text('${a.name} (${a.currency.code})'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedAccount = v),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        categoriesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, s) => const Text('Error'),
          data: (categories) {
            // Filter categories based on transaction type if they have a type
            final filtered = categories
                .where((c) => c.type.name == widget.type.name)
                .toList();
            return GestureDetector(
              onTap: () {
                _showCategoryPicker(context, filtered);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _selectedCategory == null
                        ? const Text(
                            'Select Category',
                            style: TextStyle(color: AppTheme.textSecondary),
                          )
                        : Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _selectedCategory!.color != null
                                      ? Color(_selectedCategory!.color!)
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  IconData(
                                    int.tryParse(
                                          _selectedCategory!.icon ?? '',
                                        ) ??
                                        Icons.category.codePoint,
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedCategory!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(DateFormat.yMMMd().format(_selectedDate)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text(
          'Note (optional)',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(hintText: 'What was this for?'),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _selectedAccount == null ? null : _save,
          child: const Text('Save'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _showCategoryPicker(BuildContext context, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Select Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              if (categories.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No categories found for this type.\nCreate one in the Categories tab!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: categories.length,
                    itemBuilder: (ctx, i) {
                      final c = categories[i];
                      final color = c.color != null
                          ? Color(c.color!)
                          : Colors.grey;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = c);
                          Navigator.pop(ctx);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedCategory?.id == c.id
                                      ? color
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                IconData(
                                  int.tryParse(c.icon ?? '') ??
                                      Icons.category.codePoint,
                                  fontFamily: 'MaterialIcons',
                                ),
                                color: color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              c.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _selectedCategory?.id == c.id
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TransferForm extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _TransferForm({required this.scrollController});

  @override
  ConsumerState<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<_TransferForm> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  Account? _fromAccount;
  Account? _toAccount;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_fromAccount == null ||
        _toAccount == null ||
        _amountController.text.isEmpty)
      return;
    if (_fromAccount!.id == _toAccount!.id) return;

    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final repo = ref.read(transactionRepositoryProvider);
    final intAmount = amount.round();

    final transferId = const Uuid().v4();
    final outTx = Transaction(
      id: const Uuid().v4(),
      accountId: _fromAccount!.id,
      type: TransactionType.transferOut,
      amount: intAmount,
      currency: _fromAccount!.currency,
      date: _selectedDate,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      transferId: transferId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final inTx = Transaction(
      id: const Uuid().v4(),
      accountId: _toAccount!.id,
      type: TransactionType.transferIn,
      amount:
          intAmount, // Note: no currency conversion yet, assumes same currency
      currency: _toAccount!.currency,
      date: _selectedDate,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      transferId: transferId,
      linkedTransactionId: outTx.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Link the out transaction
    final finalOutTx = outTx.copyWith(linkedTransactionId: inTx.id);

    await repo.createTransfer(transferOut: finalOutTx, transferIn: inTx);

    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(accountsListProvider);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsListProvider);

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Amount', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [MoneyInputFormatter()],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(hintText: '0'),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'From',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  accountsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, s) => const Text('Error'),
                    data: (accounts) => InputDecorator(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: DropdownButton<Account>(
                        value: _fromAccount,
                        hint: const Text('Account'),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: accounts
                            .map(
                              (a) => DropdownMenuItem(
                                value: a,
                                child: Text(
                                  '${a.name} (${a.currency.code})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _fromAccount = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  accountsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, s) => const Text('Error'),
                    data: (accounts) => InputDecorator(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: DropdownButton<Account>(
                        value: _toAccount,
                        hint: const Text('Account'),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: accounts
                            .map(
                              (a) => DropdownMenuItem(
                                value: a,
                                child: Text(
                                  '${a.name} (${a.currency.code})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _toAccount = v),
                      ),
                    ),
                  ),
                ],
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
                  const Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(DateFormat.yMMMd().format(_selectedDate)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text(
          'Note (optional)',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(hintText: 'What was this for?'),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: (_fromAccount == null || _toAccount == null)
              ? null
              : _save,
          child: const Text('Transfer'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
