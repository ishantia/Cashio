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
}
