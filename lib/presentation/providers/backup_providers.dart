import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashio/domain/services/opportunistic_backup_service.dart';
import 'package:cashio/core/providers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cashio/presentation/settings/cloud_backup_screen.dart'; // To get cloudSyncServiceProvider

final connectivityProvider = Provider((ref) => Connectivity());

final opportunisticBackupServiceProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final syncService = ref.watch(cloudSyncServiceProvider);
  final connectivity = ref.watch(connectivityProvider);
  return OpportunisticBackupService(prefs, syncService, connectivity);
});
