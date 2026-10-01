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
}
