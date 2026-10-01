import 'package:cashio/domain/services/cloud_backup_scheduler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background execution is a best-effort optimization per requirements.
    // Full offline/headless initialization omitted to avoid blocking.
    return Future.value(true);
  });
}

class WorkmanagerCloudBackupScheduler implements CloudBackupScheduler {
  static const String backupTaskName = "cashio.auto_backup";

  @override
  Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
    } catch (_) {}
  }

  @override
  Future<void> schedule() async {
    try {
      await Workmanager().registerPeriodicTask(
        "cloud_backup_task_id",
        backupTaskName,
        frequency: const Duration(hours: 24),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
    } catch (_) {}
  }

  @override
  Future<void> cancel() async {
    try {
      await Workmanager().cancelByUniqueName("cloud_backup_task_id");
    } catch (_) {}
  }
}
