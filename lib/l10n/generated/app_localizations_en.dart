// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cashio';

  @override
  String get languageSelection => 'Choose your language';

  @override
  String get continueButton => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get namePrompt => 'What should we call you?';

  @override
  String get nameHint => 'Name (Optional)';

  @override
  String get primaryCurrencyPrompt => 'Choose your primary currency';

  @override
  String get startingBalancePrompt => 'Optional starting balance';

  @override
  String get firstAccountPrompt => 'Name your first account';

  @override
  String get firstAccountHint => 'e.g., Bank Account, Cash';

  @override
  String get backupPreferencePrompt => 'Enable cloud backup?';

  @override
  String get backupPreferenceDescription =>
      'You can always change this later in settings.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get accounts => 'Accounts';

  @override
  String get settings => 'Settings';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get transfer => 'Transfer';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get addIncome => 'Add Income';

  @override
  String get addAccount => 'Add Account';

  @override
  String get search => 'Search';

  @override
  String get reports => 'Reports';

  @override
  String get budgets => 'Budgets';

  @override
  String get debts => 'Debts & Loans';

  @override
  String get recurring => 'Recurring';

  @override
  String get backup => 'Backup & Restore';

  @override
  String get exportCsv => 'Export to CSV';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get restoreWarning =>
      'Restoring this backup will replace the current local data. Are you sure?';

  @override
  String get restoreSuccess => 'Backup restored successfully.';

  @override
  String get restoreFailed => 'Failed to restore backup.';

  @override
  String get exportSuccess => 'Export successful.';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get amount => 'Amount';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get globalBudget => 'Global Budget';

  @override
  String get categoryBudget => 'Category Budget';

  @override
  String get spent => 'Spent';

  @override
  String get limit => 'Limit';

  @override
  String get noBudgets => 'No budgets recorded.';

  @override
  String get noResults => 'No results.';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get searchHint => 'Search transactions...';

  @override
  String get error => 'Error';

  @override
  String get restore => 'Restore';

  @override
  String get expenseLabel => 'Expense';

  @override
  String get noAccountsAddOne => 'No accounts. Add one!';

  @override
  String get disabled => 'Disabled';

  @override
  String get saveLabel => 'Save';

  @override
  String get noDebtsRecorded => 'No debts recorded.';

  @override
  String get noRecurringTransactions => 'No recurring transactions.';

  @override
  String get globalAllCategories => 'Global (All Categories)';

  @override
  String get recurringGeneratedOnly => 'Recurring-generated only';

  @override
  String get recurringTransactions => 'Recurring Transactions';

  @override
  String get incomeLabel => 'Income';

  @override
  String get noTransactionsFound => 'No transactions found.';

  @override
  String get pleaseCreateAccountFirst => 'Please create an account first.';

  @override
  String get transactionsLabel => 'Transactions';

  @override
  String get noBackupFound => 'No backup found.';

  @override
  String get accountsLabel => 'Accounts';

  @override
  String get noTransactionsYet => 'No transactions yet.';

  @override
  String get noAccountsFound => 'No accounts found.';

  @override
  String get apply => 'Apply';

  @override
  String get areYouSureDeleteBudget =>
      'Are you sure you want to delete this budget?';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get addTransactionLabel => 'Add Transaction';

  @override
  String get debtLinkedOnly => 'Debt-linked only';

  @override
  String get debtsAndLoans => 'Debts & Loans';
}
