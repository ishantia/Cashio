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
        _statusMessage = "Failed to list backups: ${e}";
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
        _statusMessage = "Failed: ${e}";
      });
    }
  }

  Future<void> _restoreBackup(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Restore this backup?"),
        content: const Text(
          "Your current local data will be replaced by the selected backup.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Restore", style: TextStyle(color: Colors.red)),
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
        _statusMessage = "Failed to restore: ${e}";
      });
    }
  }

  Future<void> _deleteBackup(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete backup?"),
        content: const Text(
          "Are you sure you want to delete this cloud backup?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
        _statusMessage = "Failed to delete: ${e}";
      });
    }
  }

  Future<void> _showConfigDialog() async {
    final passwordCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final tokenCtrl = TextEditingController();
    final userCtrl = TextEditingController(text: "user_default");

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Configure Cloud Backup"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(labelText: "Worker URL"),
              ),
              TextField(
                controller: tokenCtrl,
                decoration: const InputDecoration(labelText: "API Token"),
              ),
              TextField(
                controller: userCtrl,
                decoration: const InputDecoration(labelText: "User ID"),
              ),
              TextField(
                controller: passwordCtrl,
                decoration: const InputDecoration(
                  labelText: "Encryption Password",
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
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
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return "${bytes} B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastSuccess;
    try {
      final prefs = ref.watch(sharedPreferencesProvider);
      final lastSuccessStr = prefs.getString("last_successful_backup_at");
      lastSuccess = lastSuccessStr != null
          ? DateTime.parse(lastSuccessStr)
          : null;
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(title: const Text("Cloud Backup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Status: ${_statusMessage}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (!_isConfigured)
              ElevatedButton(
                onPressed: _showConfigDialog,
                child: const Text("Configure Settings"),
              )
            else ...[
              SwitchListTile(
                title: const Text("Automatic Backup"),
                subtitle: const Text("Approximately every 24 hours"),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _performBackup,
                child: const Text("Backup Now"),
              ),
              const SizedBox(height: 16),
              const Text("Backup History:"),
              Expanded(
                child: _isLoading && _backups.isEmpty
                    ? const Center(child: CircularProgressIndicator())
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
                                  icon: const Icon(Icons.download),
                                  onPressed: () =>
                                      _restoreBackup(backup.backupId),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
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
