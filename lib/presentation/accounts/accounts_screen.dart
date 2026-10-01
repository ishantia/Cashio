import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../domain/models/account.dart';
import '../../domain/models/currency.dart';
import '../../core/providers.dart';
import '../providers/data_providers.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/amount_display.dart';
import '../core/widgets/empty_state.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accountsFuture = ref.watch(accountsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accounts)),
      body: accountsFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No Accounts',
              message: l10n.noAccountsAddOne,
              actionLabel: l10n.addAccount,
              onAction: () => _showAddAccountSheet(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(accountsListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final acc = accounts[index];

                return AppCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  onTap: () {
                    // Future: Account Details Screen
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              acc.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              acc.currency.name,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AmountDisplay(
                        amount: acc.currentBalance,
                        currencyCode: acc.currency.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAccountSheet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addAccount),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddAccountSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddAccountSheet(ref: ref),
    );
  }
}

class _AddAccountSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddAccountSheet({required this.ref});

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  Currency _selectedCurrency =
      Currency.usd; // Will be overriden if IRR or Toman

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
            l10n.newAccount,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),

          Text(
            l10n.accountName,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: l10n.egMainWallet),
            autofocus: true,
          ),
          const SizedBox(height: 16),

          Text(
            l10n.initialBalance,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: '0'),
          ),
          const SizedBox(height: 16),

          Text(l10n.currency, style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: DropdownButton<Currency>(
              value: _selectedCurrency,
              isExpanded: true,
              underline: const SizedBox(),
              items: Currency.defaultCurrencies.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text('${c.name} (${c.code})'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCurrency = val);
              },
            ),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(l10n.saveAccount),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final balanceRaw =
        double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0.0;
    final initialBalance = balanceRaw.round(); // Simplified integer for MVP

    final newAccount = Account(
      id: const Uuid().v4(),
      name: name,
      currency: _selectedCurrency,
      initialBalance: initialBalance,
      currentBalance: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await widget.ref.read(accountRepositoryProvider).createAccount(newAccount);
    widget.ref.invalidate(accountsListProvider);

    if (mounted) Navigator.pop(context);
  }
}
