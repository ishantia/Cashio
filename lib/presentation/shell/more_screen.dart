import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../core/widgets/app_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Finance'),
          _buildItem(
            context,
            Icons.account_balance_wallet,
            l10n.accounts,
            '/more/accounts',
          ),
          _buildItem(context, Icons.category, 'Categories', '/more/categories'),
          _buildItem(context, Icons.money_off, l10n.debts, '/more/debts'),
          _buildItem(
            context,
            Icons.repeat,
            l10n.recurringTransactions,
            '/more/recurring',
          ),
          _buildItem(context, Icons.pie_chart, l10n.budgets, '/more/budgets'),

          const SizedBox(height: 24),
          _buildSectionHeader('App'),
          _buildItem(context, Icons.search, 'Advanced Search', '/more/search'),
          _buildItem(
            context,
            Icons.settings,
            'Settings & Backup',
            '/more/settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () => context.go(route),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
