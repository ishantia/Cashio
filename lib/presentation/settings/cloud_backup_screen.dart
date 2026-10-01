import '../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashio/domain/services/key_management_service.dart';
import 'package:cashio/domain/repositories/cloud_backup_repository.dart';
import 'package:cashio/domain/services/encryption_service.dart';
import 'package:cashio/domain/services/cloud_sync_service.dart';
import 'package:cashio/data/repositories/cloudflare_backup_repository.dart';
import 'package:cashio/data/repositories/sqflite_backup_service.dart';
import 'package:cashio/data/database/database_helper.dart';
import 'package:cashio/core/providers.dart';
import 'package:cashio/data/services/workmanager_cloud_backup_scheduler.dart';
import 'package:intl/intl.dart';

final keyManagementProvider = Provider((ref) => KeyManagementService());
final cloudBackupRepoProvider = Provider<CloudBackupRepository>((ref) {
  final keyService = ref.watch(keyManagementProvider);
  return CloudflareBackupRepository(keyService);
});
final cloudSyncServiceProvider = Provider((ref) {
  final localBackup = SqfliteBackupService(DatabaseHelper.instance);
  final encryption = EncryptionService();
  final keyService = ref.watch(keyManagementProvider);
  final repo = ref.watch(cloudBackupRepoProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return CloudSyncService(localBackup, encryption, keyService, repo, prefs);
});

class CloudBackupScreen extends ConsumerStatefulWidget {
  const CloudBackupScreen({super.key});

  @override
  ConsumerState<CloudBackupScreen> createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends ConsumerState<CloudBackupScreen> {
  bool _isConfigured = false;
  bool _isLoading = true;
  String _statusMessage = "Checking configuration...";
  List<CloudBackupMetadata> _backups = [];
  bool _automaticBackupEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkConfig();
    _loadSettings();
  }

  void _loadSettings() {
    Future.microtask(() {
      final prefs = ref.read(sharedPreferencesProvider);
      setState(() {
        _automaticBackupEnabled =
            prefs.getBool("automatic_backup_enabled") ?? false;
      });
    });
  }

  Future<void> _toggleAutomaticBackup(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool("automatic_backup_enabled", value);
    setState(() {
      _automaticBackupEnabled = value;
    });

    final scheduler = WorkmanagerCloudBackupScheduler();
    if (value) {
      await scheduler.schedule();
    } else {
      await scheduler.cancel();
    }
  }

  Future<void> _checkConfig() async {
    final keyService = ref.read(keyManagementProvider);
    final hasKey = await keyService.hasKey();
    final settings = await keyService.getCloudSettings();
    final isFullyConfigured =
        hasKey &&
        settings["api_token"] != null &&
        settings["worker_url"] != null;

    setState(() {
      _isConfigured = isFullyConfigured;
      _isLoading = false;
      _statusMessage = isFullyConfigured ? "Ready" : "Not configured";
    });

    if (isFullyConfigured) {
      _loadBackups();
    }
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    try {
      final backups = await ref.read(cloudBackupRepoProvider).listBackups();
      backups.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt); // Descending
      });
      setState(() {
        _backups = backups;
        _isLoading = false;
        _statusMessage = backups.isEmpty ? "No backups" : "Ready";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Failed to list backups: $e";
      });
    }
  }

  Future<void> _performBackup() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Preparing backup...";
    });
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(
        "last_backup_attempt_at",
        DateTime.now().toIso8601String(),
      );

      setState(() => _statusMessage = "Encrypting & Uploading...");
      final uploaded = await ref
          .read(cloudSyncServiceProvider)
          .performCloudBackup(isAutomatic: false);

      if (uploaded) {
        setState(() => _statusMessage = "Success");
        await ref.read(cloudSyncServiceProvider).enforceRetentionPolicy();
      } else {
        setState(() => _statusMessage = "Success (Deduplicated)");
      }
      _loadBackups();
    } catch (e) {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString("last_backup_error", e.toString());
      setState(() {
        _isLoading = false;
        _statusMessage = "Failed: $e";
      });
    }
  }

  Future<void> _restoreBackup(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restoreThisBackup),
        content: Text(
          l10n.restoreBackupWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.restore, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = "Restoring...";
    });
    try {
      await ref.read(cloudSyncServiceProvider).restoreCloudBackup(id);
      setState(() {
        _statusMessage = "Restore success";
      });
      _loadBackups();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Failed to restore: $e";
      });
    }
  }

  Future<void> _deleteBackup(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteBackup),
        content: Text(
          l10n.deleteBackupConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = "Deleting...";
    });
    try {
      await ref.read(cloudBackupRepoProvider).deleteBackup(id);
      setState(() {
        _statusMessage = "Deleted success";
      });
      _loadBackups();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Failed to delete: $e";
      });
    }
  }

  Future<void> _showConfigDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final passwordCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final tokenCtrl = TextEditingController();
    final userCtrl = TextEditingController(text: "user_default");

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.configureCloudBackup),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlCtrl,
                decoration: InputDecoration(labelText: l10n.workerUrl),
              ),
              TextField(
                controller: tokenCtrl,
                decoration: InputDecoration(labelText: l10n.apiToken),
              ),
              TextField(
                controller: userCtrl,
                decoration: InputDecoration(labelText: l10n.userId),
              ),
              TextField(
                controller: passwordCtrl,
                decoration: const InputDecoration(
                  labelText: l10n.encryptionPassword,
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
    final l10n = AppLocalizations.of(context)!;
                _isLoading = true;
                _statusMessage = "Configuring...";
              });
              final keyService = ref.read(keyManagementProvider);
              await keyService.saveCloudSettings(
                tokenCtrl.text,
                urlCtrl.text,
                userCtrl.text,
              );
              await keyService.generateAndStoreKeyFromPassword(
                passwordCtrl.text,
              );
              _checkConfig();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    DateTime? lastSuccess;
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      final lastSuccessStr = prefs.getString("last_successful_backup_at");
      lastSuccess = lastSuccessStr != null
          ? DateTime.parse(lastSuccessStr)
          : null;
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cloudBackup)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Status: $_statusMessage",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            if (!_isConfigured)
              ElevatedButton(
                onPressed: _showConfigDialog,
                child: Text(l10n.configureSettings),
              )
            else ...[
              SwitchListTile(
                title: Text("Automatic Backup"),
                subtitle: Text(l10n.backupFrequencyDesc),
                value: _automaticBackupEnabled,
                onChanged: _toggleAutomaticBackup,
              ),
              if (lastSuccess != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Last successful: ${DateFormat.yMMMd().add_Hm().format(lastSuccess)}",
                  ),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _performBackup,
                child: Text(l10n.backupNow),
              ),
              SizedBox(height: 16),
              Text(l10n.backupHistory),
              Expanded(
                child: _isLoading && _backups.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _backups.length,
                        itemBuilder: (context, index) {
                          final backup = _backups[index];
                          final dateStr = DateFormat.yMMMd().format(
                            backup.createdAt,
                          );

                          return ListTile(
                            title: Text(dateStr),
                            subtitle: Text(
                              "${_formatSize(backup.size)} - App v${backup.appVersion}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.download),
                                  onPressed: () =>
                                      _restoreBackup(backup.backupId),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteBackup(backup.backupId),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
