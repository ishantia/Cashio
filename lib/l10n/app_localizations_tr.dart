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
  String get languageSelection => 'Dilinizi seçin';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get skip => 'Geç';

  @override
  String get namePrompt => 'Size nasıl hitap edelim?';

  @override
  String get nameHint => 'İsim (İsteğe bağlı)';

  @override
  String get primaryCurrencyPrompt => 'Birincil para biriminizi seçin';

  @override
  String get startingBalancePrompt => 'İsteğe bağlı başlangıç bakiyesi';

  @override
  String get firstAccountPrompt => 'İlk hesabınızı isimlendirin';

  @override
  String get firstAccountHint => 'örn. Banka Hesabı, Nakit';

  @override
  String get backupPreferencePrompt => 'Bulut yedekleme etkinleştirilsin mi?';

  @override
  String get backupPreferenceDescription =>
      'Bunu daha sonra ayarlardan değiştirebilirsiniz.';

  @override
  String get dashboard => 'Gösterge Paneli';

  @override
  String get transactions => 'İşlemler';

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
  String get transfer => l10n.transfer;
}
