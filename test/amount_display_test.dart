import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cashio/presentation/core/widgets/amount_display.dart';
import 'package:cashio/domain/models/transaction.dart';

void main() {
  group('AmountDisplay widget', () {
    testWidgets('shows correct signs based on transaction type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AmountDisplay(amount: 50000, currencyCode: 'USD', type: TransactionType.expense),
                AmountDisplay(amount: 50000, currencyCode: 'USD', type: TransactionType.income),
                AmountDisplay(amount: 50000, currencyCode: 'USD', type: TransactionType.transferOut),
                AmountDisplay(amount: 50000, currencyCode: 'USD', type: TransactionType.income, forceSign: true),
              ],
            ),
          ),
        ),
      );

      expect(find.text('-\$50,000'), findsOneWidget);
      expect(find.text('+\$50,000'), findsOneWidget);
      expect(find.text('\$50,000'), findsNWidgets(2));
    });
  });
}