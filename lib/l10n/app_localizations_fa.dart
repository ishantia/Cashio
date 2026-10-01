// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'کشیو';

  @override
  String get languageSelection => 'زبان خود را انتخاب کنید';

  @override
  String get continueButton => 'ادامه';

  @override
  String get skip => 'رد شدن';

  @override
  String get namePrompt => 'نام شما چیست؟';

  @override
  String get nameHint => 'نام (اختیاری)';

  @override
  String get primaryCurrencyPrompt => 'ارز اصلی خود را انتخاب کنید';

  @override
  String get startingBalancePrompt => 'موجودی اولیه (اختیاری)';

  @override
  String get firstAccountPrompt => 'نام اولین حساب خود را وارد کنید';

  @override
  String get firstAccountHint => 'مثال: حساب بانکی، پول نقد';

  @override
  String get backupPreferencePrompt => 'پشتیبان‌گیری ابری فعال شود؟';

  @override
  String get backupPreferenceDescription =>
      'بعداً می‌توانید این تنظیم را تغییر دهید.';

  @override
  String get dashboard => 'داشبورد';

  @override
  String get transactions => 'تراکنش‌ها';

  @override
  String get accounts => 'حساب‌ها';

  @override
  String get settings => 'تنظیمات';

  @override
  String get totalBalance => 'موجودی کل';

  @override
  String get income => 'درآمد';

  @override
  String get expense => 'هزینه';

  @override
  String get transfer => 'انتقال';
}
