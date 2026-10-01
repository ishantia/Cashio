import 'package:flutter_test/flutter_test.dart';
import 'package:cashio/presentation/core/utils/money_formatter.dart';

void main() {
  group('MoneyInputFormatter', () {
    test('formats numbers with commas', () {
      final formatter = MoneyInputFormatter();

      final result1 = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        const TextEditingValue(text: '500'),
      );
      expect(result1.text, '500');

      final result2 = formatter.formatEditUpdate(
        const TextEditingValue(text: '500'),
        const TextEditingValue(text: '5000'),
      );
      expect(result2.text, '5,000');

      final result3 = formatter.formatEditUpdate(
        const TextEditingValue(text: '5,000'),
        const TextEditingValue(text: '50000'),
      );
      expect(result3.text, '50,000');
    });

    test('parseInt parses formatted and unformatted strings correctly', () {
      expect(MoneyInputFormatter.parseInt('50,000'), 50000);
      expect(MoneyInputFormatter.parseInt('50000'), 50000);
      expect(MoneyInputFormatter.parseInt('0'), 0);
      expect(MoneyInputFormatter.parseInt(''), 0);
      expect(MoneyInputFormatter.parseInt('abc'), 0);
    });
  });
}
