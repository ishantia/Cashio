abstract class BackupService {
  /// Exports all data to a JSON string
  Future<String> exportBackup();

  /// Validates the JSON structure and schema compatibility
  Future<bool> validateBackup(String jsonContent);

  /// Restores data from JSON, clearing existing data completely. Rolls back on error.
  Future<void> restoreBackup(String jsonContent);
}
