abstract class CloudBackupScheduler {
  Future<void> initialize();
  Future<void> schedule();
  Future<void> cancel();
}
