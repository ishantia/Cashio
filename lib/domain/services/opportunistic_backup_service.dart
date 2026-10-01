import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cashio/domain/services/cloud_sync_service.dart';

class OpportunisticBackupService {
  final SharedPreferences _prefs;
  final CloudSyncService _syncService;
  final Connectivity _connectivity;

  OpportunisticBackupService(
    this._prefs,
    this._syncService,
    this._connectivity,
  );

  Future<void> checkAndRunBackup() async {
    try {
      final enabled = _prefs.getBool('automatic_backup_enabled') ?? false;
      if (!enabled) return;

      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) return;

      final lastSuccessStr = _prefs.getString('last_successful_backup_at');
      final frequencyHours = _prefs.getInt('backup_frequency_hours') ?? 24;

      if (lastSuccessStr != null) {
        final lastSuccess = DateTime.parse(lastSuccessStr);
        if (DateTime.now().difference(lastSuccess).inHours < frequencyHours) {
          return;
        }
      }

      await runBackup();
    } catch (e) {
      // Opportunistic backup should never throw and block UI
    }
  }

  Future<void> runBackup() async {
    try {
      await _prefs.setString(
        'last_backup_attempt_at',
        DateTime.now().toIso8601String(),
      );

      final uploaded = await _syncService.performCloudBackup(isAutomatic: true);
      if (uploaded) {
        await _prefs.setString(
          'last_successful_backup_at',
          DateTime.now().toIso8601String(),
        );
        await _prefs.remove('last_backup_error');

        // Handle retention
        await _syncService.enforceRetentionPolicy();
      }
    } catch (e) {
      await _prefs.setString('last_backup_error', e.toString());
    }
  }
}
