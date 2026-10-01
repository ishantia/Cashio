import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../providers/data_providers.dart';
import '../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final backupJson = await ref.read(backupServiceProvider).exportBackup();
      final path = await ref
          .read(fileIoServiceProvider)
          .saveFile(fileName: 'cashio_backup.json', content: backupJson);

      if (context.mounted && path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)!.exportSuccess} Saved to: $path",
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    // Explicit confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.restoreBackup),
        content: Text(AppLocalizations.of(context)!.restoreWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final path = await ref
          .read(fileIoServiceProvider)
          .pickFile(allowedExtensions: ['json']);

      if (path == null) {
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noBackupFound),
            ),
          );
        return;
      }

      final content = await File(path).readAsString();
      await ref.read(backupServiceProvider).restoreBackup(content);

      // Refresh all providers
      ref.invalidate(transactionRepositoryProvider);
      ref.invalidate(accountRepositoryProvider);
      ref.invalidate(categoryRepositoryProvider);
      ref.invalidate(debtRepositoryProvider);
      ref.invalidate(recurringTransactionRepositoryProvider);
      ref.invalidate(budgetRepositoryProvider);
      ref.invalidate(dashboardAggregationsProvider);
      ref.invalidate(accountsListProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.restoreSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppLocalizations.of(context)!.restoreFailed}\n$e"),
          ),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final csv = await ref
          .read(csvExportServiceProvider)
          .exportTransactionsToCsv();
      final path = await ref
          .read(fileIoServiceProvider)
          .saveFile(fileName: 'cashio_transactions.csv', content: csv);

      if (context.mounted && path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)!.exportSuccess} Saved to: $path",
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(AppLocalizations.of(context)!.createBackup),
            onTap: () => _exportBackup(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(AppLocalizations.of(context)!.restoreBackup),
            onTap: () => _restoreBackup(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: Text(AppLocalizations.of(context)!.exportCsv),
            onTap: () => _exportCsv(context, ref),
          ),
        ],
      ),
    );
  }
}
