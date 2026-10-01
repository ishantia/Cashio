import '../domain/repositories/budget_repository.dart';
import '../data/repositories/sqflite_budget_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/database_helper.dart';
import '../data/repositories/sqflite_account_repository.dart';
import '../domain/repositories/account_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/repositories/debt_repository.dart';
import '../domain/repositories/recurring_transaction_repository.dart';
import '../domain/services/file_io_service.dart';
import '../data/repositories/fallback_file_io_service.dart';
import '../domain/services/backup_service.dart';
import '../domain/services/csv_export_service.dart';
import '../domain/usecases/calculate_account_balance.dart';
import '../domain/usecases/calculate_debt_balance.dart';
import '../domain/usecases/process_recurring_transactions.dart';
import '../data/repositories/sqflite_category_repository.dart';
import '../data/repositories/sqflite_transaction_repository.dart';
import '../data/repositories/sqflite_debt_repository.dart';
import '../data/repositories/sqflite_recurring_repository.dart';
import '../data/repositories/sqflite_backup_service.dart';
import '../data/repositories/sqflite_csv_export_service.dart';

// Provides SharedPreferences (must be overridden in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Database
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Repositories
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqfliteAccountRepository(dbHelper);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqfliteCategoryRepository(dbHelper);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqfliteTransactionRepository(dbHelper);
});

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqfliteDebtRepository(dbHelper);
});

final recurringTransactionRepositoryProvider =
    Provider<RecurringTransactionRepository>((ref) {
      final dbHelper = ref.watch(databaseHelperProvider);
      return SqfliteRecurringTransactionRepository(dbHelper);
    });

final backupServiceProvider = Provider<BackupService>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqfliteBackupService(dbHelper);
});

final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqfliteCsvExportService(dbHelper);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SqfliteBudgetRepository(dbHelper);
});

final fileIoServiceProvider = Provider<FileIoService>((ref) {
  return FallbackFileIoService();
});

// Use Cases
final calculateAccountBalanceProvider = Provider<CalculateAccountBalance>((
  ref,
) {
  return CalculateAccountBalance(ref.watch(transactionRepositoryProvider));
});

final calculateDebtBalanceProvider = Provider<CalculateDebtBalance>((ref) {
  return CalculateDebtBalance(ref.watch(transactionRepositoryProvider));
});

final processRecurringTransactionsProvider =
    Provider<ProcessRecurringTransactions>((ref) {
      return ProcessRecurringTransactions(
        ref.watch(recurringTransactionRepositoryProvider),
        ref.watch(transactionRepositoryProvider),
      );
    });

final appInitProvider = FutureProvider<void>((ref) async {
  // Run startup routines
  final engine = ref.watch(processRecurringTransactionsProvider);
  await engine.execute();
});

// Providers for App State like Language/Locale
final localeProvider = NotifierProvider<LocaleNotifier, String?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<String?> {
  static const _localeKey = 'app_locale';

  @override
  String? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_localeKey);
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_localeKey, languageCode);
    state = languageCode;
  }
}

// Onboarding Provider
final onboardingCompleteProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<bool> {
  static const _onboardingKey = 'onboarding_complete';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_onboardingKey, true);
    state = true;
  }
}
