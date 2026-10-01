import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('All ARB files should have the exact same keys as app_en.arb', () {
    final l10nDir = Directory('lib/l10n');
    final enFile = File('${l10nDir.path}/app_en.arb');
    
    expect(enFile.existsSync(), isTrue, reason: 'app_en.arb must exist');

    final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
    final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();

    final arbFiles = l10nDir.listSync().whereType<File>().where((f) => f.path.endsWith('.arb'));

    for (final file in arbFiles) {
      if (file.path.endsWith('app_en.arb')) continue;

      final locale = file.uri.pathSegments.last.replaceAll('.arb', '').replaceAll('app_', '');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final keys = json.keys.where((k) => !k.startsWith('@')).toSet();

      final missingInLocale = enKeys.difference(keys);
      final extraInLocale = keys.difference(enKeys);

      if (missingInLocale.isNotEmpty || extraInLocale.isNotEmpty) {
        fail('''
Localization mismatch in $locale:
Missing keys (exist in EN but not in $locale): $missingInLocale
Extra keys (exist in $locale but not in EN): $extraInLocale
''');
      }
    }
  });
}
