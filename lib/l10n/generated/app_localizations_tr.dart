// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Cashio';

  @override
  String get languageSelection => 'Dilinizi seÃ§in';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get skip => 'GeÃ§';

  @override
  String get namePrompt => 'Size nasÄ±l hitap edelim?';

  @override
  String get nameHint => 'Ä°sim (Ä°steÄe baÄlÄ±)';

  @override
  String get primaryCurrencyPrompt => 'Birincil para biriminizi seÃ§in';

  @override
  String get startingBalancePrompt => 'Ä°steÄe baÄlÄ± baÅlangÄ±Ã§ bakiyesi';

  @override
  String get firstAccountPrompt => 'Ä°lk hesabÄ±nÄ±zÄ± isimlendirin';

  @override
  String get firstAccountHint => 'Ã¶rn. Banka HesabÄ±, Nakit';

  @override
  String get backupPreferencePrompt => 'Bulut yedekleme etkinleÅtirilsin mi?';

  @override
  String get backupPreferenceDescription =>
      'Bunu daha sonra ayarlardan deÄiÅtirebilirsiniz.';

  @override
  String get dashboard => 'GÃ¶sterge Paneli';

  @override
  String get transactions => 'Ä°Ålemler';

  @override
  String get accounts => 'Hesaplar';

  @override
  String get settings => 'Ayarlar';

  @override
  String get totalBalance => 'Toplam Bakiye';

  @override
  String get income => 'Gelir';

  @override
  String get expense => 'Gider';

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
  String get budgets => 'Bütçeler';

  @override
  String get debts => 'Debts';

  @override
  String get recurring => 'Recurring';

  @override
  String get backup => 'Backup';

  @override
  String get exportCsv => 'CSV Dışa Aktar';

  @override
  String get createBackup => 'Yedek Oluştur';

  @override
  String get restoreBackup => 'Yedeği Geri Yükle';

  @override
  String get restoreWarning => 'Uyarı: Veritabanı değiştirilecek.';

  @override
  String get restoreSuccess => 'Geri yükleme başarılı.';

  @override
  String get restoreFailed => 'Geri yükleme başarısız.';

  @override
  String get exportSuccess => 'Disa aktarildi.';

  @override
  String get addBudget => 'Bütçe Ekle';

  @override
  String get amount => 'Amount';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'Iptal';

  @override
  String get globalBudget => 'Genel';

  @override
  String get categoryBudget => 'Kategori';

  @override
  String get spent => 'Harcanan';

  @override
  String get limit => 'Sinir';

  @override
  String get noBudgets => 'Bütçe yok.';

  @override
  String get noResults => 'Sonuç yok.';

  @override
  String get clearFilters => 'Temizle';

  @override
  String get searchHint => 'Ara...';

  @override
  String get error => 'Hata';

  @override
  String get restore => 'Geri Yükle';

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

  @override
  String get apiToken => 'API Token';

  @override
  String get account => 'Account';

  @override
  String get accountName => 'Account Name';

  @override
  String get add => 'Add';

  @override
  String get addCategory => 'Add Category';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get addRecurring => 'Add Recurring';

  @override
  String get addRecurringTransaction => 'Add Recurring Transaction';

  @override
  String get advancedFilters => 'Advanced Filters';

  @override
  String get automaticBackup => 'Automatic Backup';

  @override
  String get backupFrequencyDesc => 'Approximately every 24 hours';

  @override
  String get deleteRecurringConfirm =>
      'Are you sure you want to delete this automation? Past transactions will remain.';

  @override
  String get deleteBudgetConfirm =>
      'Are you sure you want to delete this budget?';

  @override
  String get deleteBackupConfirm =>
      'Are you sure you want to delete this cloud backup?';

  @override
  String get deleteDebtConfirm =>
      'Are you sure you want to delete this debt? Transactions linked to it will not be deleted, but the link will be lost.';

  @override
  String get deleteTransactionConfirm =>
      'Are you sure you want to delete this transaction?';

  @override
  String get backupHistory => 'Backup History:';

  @override
  String get backupNow => 'Backup Now';

  @override
  String get cashFlow => 'Cash Flow';

  @override
  String get categories => 'Categories';

  @override
  String get category => 'Category';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get color => 'Color';

  @override
  String get configureCloudBackup => 'Configure Cloud Backup';

  @override
  String get configureSettings => 'Configure Settings';

  @override
  String get currency => 'Currency';

  @override
  String get date => 'Date';

  @override
  String get delete => 'Delete';

  @override
  String get deleteDebt => 'Delete Debt';

  @override
  String get deleteRecurring => 'Delete Recurring';

  @override
  String get deleteTransaction => 'Delete Transaction?';

  @override
  String get deleteBackup => 'Delete backup?';

  @override
  String get dueDateOptional => 'Due Date (Optional)';

  @override
  String get dueDate => 'Due: ';

  @override
  String get edit => 'Edit';

  @override
  String get encryptionPassword => 'Encryption Password';

  @override
  String get errorLoadingAccounts => 'Error loading accounts';

  @override
  String get expenses => 'Expenses';

  @override
  String get fromText => 'From';

  @override
  String get iOwe => 'I Owe';

  @override
  String get icon => 'Icon';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get maxAmount => 'Max Amount';

  @override
  String get minAmount => 'Min Amount';

  @override
  String get name => 'Name';

  @override
  String get netFlow => 'Net Flow';

  @override
  String get netWorth => 'Net Worth';

  @override
  String get newAccount => 'New Account';

  @override
  String get nextDate => 'Next Date';

  @override
  String get noAccountsSetUp => 'No accounts set up.';

  @override
  String get noCategoriesFound =>
      'No categories found for this type.\\nCreate one in the Categories tab!';

  @override
  String get noteOptional => 'Note (Optional)';

  @override
  String get noteTitle => 'Note / Title';

  @override
  String get owesMe => 'Owes Me';

  @override
  String get personEntityName => 'Person / Entity Name';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get recordDebt => 'Record Debt';

  @override
  String get repeats => 'Repeats';

  @override
  String get restoreThisBackup => 'Restore this backup?';

  @override
  String get saveAccount => 'Save Account';

  @override
  String get saveCategory => 'Save Category';

  @override
  String get saveDebt => 'Save Debt';

  @override
  String get saveRule => 'Save Rule';

  @override
  String get seeAll => 'See All';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get startDate => 'Start Date';

  @override
  String get to => 'To';

  @override
  String get topSpending => 'Top Spending';

  @override
  String get total => 'Total: ';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get type => 'Type';

  @override
  String get userId => 'User ID';

  @override
  String get whatWasThisFor => 'What was this for?';

  @override
  String get workerUrl => 'Worker URL';

  @override
  String get restoreBackupWarning =>
      'Your current local data will be replaced by the selected backup.';

  @override
  String get egForDinner => 'e.g. For dinner last night';

  @override
  String get egGroceries => 'e.g. Groceries';

  @override
  String get egJohnDoe => 'e.g. John Doe';

  @override
  String get egMainWallet => 'e.g. Main Wallet';

  @override
  String get egNetflix => 'e.g. Netflix Subscription';

  @override
  String get egPartialPayment => 'e.g. Partial payment';

  @override
  String get ofText => 'of';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get today => 'Today';

  @override
  String get custom => 'Custom';

  @override
  String get all => 'All';

  @override
  String get status => 'Status: ';

  @override
  String get noReportsYet => 'No reports yet';

  @override
  String get addTransactionsToSee =>
      'Add some transactions to see your financial activity.';
}
