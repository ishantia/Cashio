// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'كاشيو';

  @override
  String get languageSelection => 'اختر لغتك';

  @override
  String get continueButton => 'متابعة';

  @override
  String get skip => 'تخطي';

  @override
  String get namePrompt => 'ماذا يجب أن نناديك؟';

  @override
  String get nameHint => 'الاسم (اختياري)';

  @override
  String get primaryCurrencyPrompt => 'اختر عملتك الأساسية';

  @override
  String get startingBalancePrompt => 'الرصيد الافتتاحي (اختياري)';

  @override
  String get firstAccountPrompt => 'اسم حسابك الأول';

  @override
  String get firstAccountHint => 'مثل: حساب بنكي، نقد';

  @override
  String get backupPreferencePrompt => 'تمكين النسخ الاحتياطي السحابي؟';

  @override
  String get backupPreferenceDescription =>
      'يمكنك تغيير هذا لاحقًا في الإعدادات.';

  @override
  String get dashboard => 'لوحة القيادة';

  @override
  String get transactions => 'المعاملات';

  @override
  String get accounts => 'الحسابات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get totalBalance => 'الرصيد الإجمالي';

  @override
  String get income => 'دخل';

  @override
  String get expense => 'مصروف';

  @override
  String get transfer => 'تحويل';

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
  String get reports => 'التقارير';

  @override
  String get budgets => 'ميزانيات';

  @override
  String get debts => 'Debts';

  @override
  String get recurring => 'Recurring';

  @override
  String get backup => 'Backup';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get createBackup => 'إنشاء نسخة احتياطية';

  @override
  String get restoreBackup => 'استعادة نسخة احتياطية';

  @override
  String get restoreWarning => 'تحذير: سيتم استبدال قاعدة البيانات.';

  @override
  String get restoreSuccess => 'استعادة ناجحة.';

  @override
  String get restoreFailed => 'فشل الاستعادة.';

  @override
  String get exportSuccess => '?? ???????.';

  @override
  String get addBudget => '????? ???????';

  @override
  String get amount => 'Amount';

  @override
  String get save => '???';

  @override
  String get cancel => '?????';

  @override
  String get globalBudget => '????';

  @override
  String get categoryBudget => '???';

  @override
  String get spent => '?????';

  @override
  String get limit => '??';

  @override
  String get noBudgets => '?? ???? ????????.';

  @override
  String get noResults => '?? ?????.';

  @override
  String get clearFilters => '???';

  @override
  String get searchHint => '???...';

  @override
  String get error => '???';

  @override
  String get restore => '???????';

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
  String get apiToken => 'رمز API';

  @override
  String get account => 'حساب';

  @override
  String get accountName => 'اسم الحساب';

  @override
  String get add => 'إضافة';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get addDebt => 'إضافة دين';

  @override
  String get addRecurring => 'إضافة متكرر';

  @override
  String get addRecurringTransaction => 'إضافة معاملة متكررة';

  @override
  String get advancedFilters => 'تصفية متقدمة';

  @override
  String get automaticBackup => 'نسخ احتياطي تلقائي';

  @override
  String get backupFrequencyDesc => 'كل 24 ساعة تقريباً';

  @override
  String get deleteRecurringConfirm =>
      'هل أنت متأكد من حذف هذه الأتمتة؟ ستبقى المعاملات السابقة.';

  @override
  String get deleteBudgetConfirm => 'هل أنت متأكد من حذف هذه الميزانية؟';

  @override
  String get deleteBackupConfirm =>
      'هل أنت متأكد من حذف هذه النسخة الاحتياطية؟';

  @override
  String get deleteDebtConfirm =>
      'هل أنت متأكد من حذف هذا الدين؟ لن يتم حذف المعاملات المرتبطة به.';

  @override
  String get deleteTransactionConfirm => 'هل أنت متأكد من حذف هذه المعاملة؟';

  @override
  String get backupHistory => 'تاريخ النسخ الاحتياطي:';

  @override
  String get backupNow => 'النسخ الآن';

  @override
  String get cashFlow => 'التدفق النقدي';

  @override
  String get categories => 'الفئات';

  @override
  String get category => 'فئة';

  @override
  String get cloudBackup => 'النسخ السحابي';

  @override
  String get color => 'لون';

  @override
  String get configureCloudBackup => 'إعداد النسخ السحابي';

  @override
  String get configureSettings => 'إعدادات';

  @override
  String get currency => 'العملة';

  @override
  String get date => 'التاريخ';

  @override
  String get delete => 'حذف';

  @override
  String get deleteDebt => 'حذف الدين';

  @override
  String get deleteRecurring => 'حذف المتكرر';

  @override
  String get deleteTransaction => 'حذف المعاملة؟';

  @override
  String get deleteBackup => 'حذف النسخة؟';

  @override
  String get dueDateOptional => 'تاريخ الاستحقاق (اختياري)';

  @override
  String get dueDate => 'الاستحقاق: ';

  @override
  String get edit => 'تعديل';

  @override
  String get encryptionPassword => 'كلمة مرور التشفير';

  @override
  String get errorLoadingAccounts => 'خطأ في تحميل الحسابات';

  @override
  String get expenses => 'المصروفات';

  @override
  String get fromText => 'من';

  @override
  String get iOwe => 'أنا مدين';

  @override
  String get icon => 'أيقونة';

  @override
  String get initialBalance => 'الرصيد الافتتاحي';

  @override
  String get maxAmount => 'الحد الأقصى';

  @override
  String get minAmount => 'الحد الأدنى';

  @override
  String get name => 'الاسم';

  @override
  String get netFlow => 'صافي التدفق';

  @override
  String get netWorth => 'صافي الثروة';

  @override
  String get newAccount => 'حساب جديد';

  @override
  String get nextDate => 'التاريخ التالي';

  @override
  String get noAccountsSetUp => 'لم يتم إعداد حسابات.';

  @override
  String get noCategoriesFound =>
      'لم يتم العثور على فئات.\\nقم بإنشاء واحدة في علامة تبويب الفئات!';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get noteTitle => 'ملاحظة / عنوان';

  @override
  String get owesMe => 'يدين لي';

  @override
  String get personEntityName => 'اسم الشخص / الجهة';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get recordDebt => 'تسجيل الدين';

  @override
  String get repeats => 'يتكرر';

  @override
  String get restoreThisBackup => 'استعادة هذه النسخة؟';

  @override
  String get saveAccount => 'حفظ الحساب';

  @override
  String get saveCategory => 'حفظ الفئة';

  @override
  String get saveDebt => 'حفظ الدين';

  @override
  String get saveRule => 'حفظ القاعدة';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get selectAccount => 'اختر الحساب';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get spendingByCategory => 'الإنفاق حسب الفئة';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get to => 'إلى';

  @override
  String get topSpending => 'أعلى الإنفاق';

  @override
  String get total => 'الإجمالي: ';

  @override
  String get transactionDeleted => 'تم حذف المعاملة';

  @override
  String get type => 'النوع';

  @override
  String get userId => 'معرف المستخدم';

  @override
  String get whatWasThisFor => 'لأي غرض كان هذا؟';

  @override
  String get workerUrl => 'رابط Worker';

  @override
  String get restoreBackupWarning =>
      'سيتم استبدال بياناتك المحلية الحالية بالنسخة الاحتياطية المحددة.';

  @override
  String get egForDinner => 'مثلاً لعشاء البارحة';

  @override
  String get egGroceries => 'مثلاً بقالة';

  @override
  String get egJohnDoe => 'مثلاً أحمد محمد';

  @override
  String get egMainWallet => 'مثلاً المحفظة الرئيسية';

  @override
  String get egNetflix => 'مثلاً اشتراك نتفليكس';

  @override
  String get egPartialPayment => 'مثلاً دفعة جزئية';

  @override
  String get ofText => 'من';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get thisYear => 'هذا العام';

  @override
  String get today => 'اليوم';

  @override
  String get custom => 'مخصص';

  @override
  String get all => 'الكل';

  @override
  String get status => 'الحالة: ';

  @override
  String get noReportsYet => 'لا توجد تقارير بعد';

  @override
  String get addTransactionsToSee => 'أضف بعض المعاملات لرؤية نشاطك المالي.';
}
