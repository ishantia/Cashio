// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Cashio';

  @override
  String get languageSelection => 'Wähle deine Sprache';

  @override
  String get continueButton => 'Weiter';

  @override
  String get skip => 'Überspringen';

  @override
  String get namePrompt => 'Wie sollen wir dich nennen?';

  @override
  String get nameHint => 'Name (Optional)';

  @override
  String get primaryCurrencyPrompt => 'Wähle deine Hauptwährung';

  @override
  String get startingBalancePrompt => 'Optionales Startguthaben';

  @override
  String get firstAccountPrompt => 'Benenne dein erstes Konto';

  @override
  String get firstAccountHint => 'z.B. Bankkonto, Bargeld';

  @override
  String get backupPreferencePrompt => 'Cloud-Backup aktivieren?';

  @override
  String get backupPreferenceDescription =>
      'Du kannst dies später in den Einstellungen ändern.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transaktionen';

  @override
  String get accounts => 'Konten';

  @override
  String get settings => 'Einstellungen';

  @override
  String get totalBalance => 'Gesamtsaldo';

  @override
  String get income => 'Einkommen';

  @override
  String get expense => 'Ausgabe';

  @override
  String get transfer => 'Überweisung';
}
