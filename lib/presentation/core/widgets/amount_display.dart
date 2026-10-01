import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:ui' as ui;

import '../../../domain/models/transaction.dart';
import '../theme/app_theme.dart';

class AmountDisplay extends StatelessWidget {
  final int amount;
  final String currencyCode;
  final TextStyle? style;
  final TransactionType? type; // Determines semantic sign/color
  final bool forceSign;

  const AmountDisplay({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.style,
    this.type,
    this.forceSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(
      symbol: _getSymbol(currencyCode),
      decimalDigits: 0,
    );

    String text = format.format(amount.abs());

    // Determine presentation sign
    String prefix = '';
    Color? color = style?.color;

    if (type == TransactionType.income) {
      prefix = forceSign ? '+' : '';
      color = AppTheme.success;
    } else if (type == TransactionType.expense) {
      prefix = '-';
      color = AppTheme.danger;
    } else if (type == TransactionType.transferIn || type == TransactionType.transferOut) {
      prefix = '';
      color = AppTheme.textPrimary; // Neutral
    } else {
      // Fallback if no type is given, rely on mathematical sign
      if (amount > 0) {
        prefix = forceSign ? '+' : '';
        if (forceSign) color = AppTheme.success;
      } else if (amount < 0) {
        prefix = '-';
        if (forceSign) color = AppTheme.danger;
      }
    }

    return Text(
      '$prefix$text',
      style:
          style?.copyWith(color: color) ??
          TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
            fontFeatures: const [ui.FontFeature.tabularFigures()],
          ),
      textDirection: ui
          .TextDirection
          .ltr, // Ensure amounts always flow LTR even in Persian
    );
  }

  static String _getSymbol(String code) {
    switch (code.toUpperCase()) {
      case 'IRR':
        return 'IRR ';
      case 'TOMAN':
        return 'T ';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '$code ';
    }
  }
}
