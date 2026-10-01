import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String code; // e.g. 'IRR', 'TOMAN', 'USD'
  final String symbol; // e.g. 'ریال', 'تومان', '$'
  final String name;
  final int fractionalDigits; // e.g. 2 for USD, 0 for IRR/TOMAN

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.fractionalDigits,
  });

  @override
  List<Object?> get props => [code, symbol, name, fractionalDigits];

  static const Currency irr = Currency(
    code: 'IRR',
    symbol: 'ریال',
    name: 'Iranian Rial',
    fractionalDigits: 0,
  );
  static const Currency toman = Currency(
    code: 'TOMAN',
    symbol: 'تومان',
    name: 'Iranian Toman',
    fractionalDigits: 0,
  );
  static const Currency usd = Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    fractionalDigits: 2,
  );
  static const Currency eur = Currency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    fractionalDigits: 2,
  );
  static const Currency gbp = Currency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    fractionalDigits: 2,
  );
  static const Currency aed = Currency(
    code: 'AED',
    symbol: 'د.إ',
    name: 'UAE Dirham',
    fractionalDigits: 2,
  );
  static const Currency tryLira = Currency(
    code: 'TRY',
    symbol: '₺',
    name: 'Turkish Lira',
    fractionalDigits: 2,
  );

  static const List<Currency> defaultCurrencies = [
    irr,
    toman,
    usd,
    eur,
    gbp,
    aed,
    tryLira,
  ];

  static Currency fromCode(String code) {
    return defaultCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => usd, // fallback
    );
  }
}

class Money extends Equatable {
  /// The amount stored as an integer of the smallest currency unit.
  /// For USD: $10.50 is 1050 cents.
  /// For TOMAN: 10,000 Toman is 10000.
  final int amount;
  final Currency currency;

  const Money({required this.amount, required this.currency});

  /// Explicit handling for Toman and Rial relationship
  Money convertTo(Currency targetCurrency) {
    if (currency == targetCurrency) return this;

    // Toman <-> Rial conversions (1 Toman = 10 Rial)
    if (currency == Currency.irr && targetCurrency == Currency.toman) {
      return Money(amount: amount ~/ 10, currency: Currency.toman);
    }
    if (currency == Currency.toman && targetCurrency == Currency.irr) {
      return Money(amount: amount * 10, currency: Currency.irr);
    }

    // For other currency conversions, we would need exchange rates.
    // Throwing an error for now to enforce architecture.
    throw UnimplementedError(
      'Exchange rates between ${currency.code} and ${targetCurrency.code} not supported yet.',
    );
  }

  @override
  List<Object?> get props => [amount, currency];
}
