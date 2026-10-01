// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Cashio';

  @override
  String get languageSelection => 'Choisissez votre langue';

  @override
  String get continueButton => 'Continuer';

  @override
  String get skip => 'Passer';

  @override
  String get namePrompt => 'Comment devons-nous vous appeler ?';

  @override
  String get nameHint => 'Nom (Optionnel)';

  @override
  String get primaryCurrencyPrompt => 'Choisissez votre devise principale';

  @override
  String get startingBalancePrompt => 'Solde de départ optionnel';

  @override
  String get firstAccountPrompt => 'Nommez votre premier compte';

  @override
  String get firstAccountHint => 'ex. Compte bancaire, Espèces';

  @override
  String get backupPreferencePrompt => 'Activer la sauvegarde dans le cloud ?';

  @override
  String get backupPreferenceDescription =>
      'Vous pourrez modifier cela plus tard dans les paramètres.';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get transactions => 'Transactions';

  @override
  String get accounts => 'Comptes';

  @override
  String get settings => 'Paramètres';

  @override
  String get totalBalance => 'Solde total';

  @override
  String get income => 'Revenu';

  @override
  String get expense => 'Dépense';

  @override
  String get transfer => 'Virement';
}
