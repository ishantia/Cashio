// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Cashio';

  @override
  String get languageSelection => 'Elige tu idioma';

  @override
  String get continueButton => 'Continuar';

  @override
  String get skip => 'Saltar';

  @override
  String get namePrompt => '¿Cómo deberíamos llamarte?';

  @override
  String get nameHint => 'Nombre (Opcional)';

  @override
  String get primaryCurrencyPrompt => 'Elige tu moneda principal';

  @override
  String get startingBalancePrompt => 'Saldo inicial opcional';

  @override
  String get firstAccountPrompt => 'Nombra tu primer saldo';

  @override
  String get firstAccountHint => 'ej. Cuenta bancaria, Efectivo';

  @override
  String get backupPreferencePrompt =>
      '¿Habilitar copia de seguridad en la nube?';

  @override
  String get backupPreferenceDescription =>
      'Puedes cambiar esto más tarde en la configuración.';

  @override
  String get dashboard => 'Panel de control';

  @override
  String get transactions => 'Transacciones';

  @override
  String get accounts => 'Cuentas';

  @override
  String get settings => 'Configuraciones';

  @override
  String get totalBalance => 'Saldo total';

  @override
  String get income => 'Ingreso';

  @override
  String get expense => 'Gasto';

  @override
  String get transfer => 'Transferencia';
}
