import 'package:flutter_test/flutter_test.dart';
import 'package:cashio/domain/models/currency.dart';

void main() {
  group('Currency Models', () {
    test('Currency object equality', () {
      const usd1 = Currency(
        code: 'USD',
        symbol: '\$',
        name: 'US Dollar',
        fractionalDigits: 2,
      );
      const usd2 = Currency.usd;
      expect(usd1, equals(usd2));
    });

    test('Currency fromCode fallback', () {
      final fallback = Currency.fromCode('UNKNOWN');
      expect(fallback, equals(Currency.usd));
    });
  });

  group('Money Conversions (IRR <-> TOMAN)', () {
    test('Convert Rial to Toman', () {
      const moneyInRial = Money(amount: 10000, currency: Currency.irr);
      final moneyInToman = moneyInRial.convertTo(Currency.toman);

      expect(moneyInToman.amount, equals(1000));
      expect(moneyInToman.currency, equals(Currency.toman));
    });

    test('Convert Toman to Rial', () {
      const moneyInToman = Money(amount: 1000, currency: Currency.toman);
      final moneyInRial = moneyInToman.convertTo(Currency.irr);

      expect(moneyInRial.amount, equals(10000));
      expect(moneyInRial.currency, equals(Currency.irr));
    });

    test('Convert to same currency does nothing', () {
      const money = Money(amount: 500, currency: Currency.usd);
      final converted = money.convertTo(Currency.usd);

      expect(converted.amount, equals(500));
      expect(converted.currency, equals(Currency.usd));
    });

    test('Convert unsupported currencies throws error', () {
      const money = Money(amount: 100, currency: Currency.usd);
      expect(
        () => money.convertTo(Currency.eur),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
