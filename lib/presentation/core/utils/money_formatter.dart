import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoneyInputFormatter extends TextInputFormatter {
  static final _numberFormat = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Return empty if empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digits
    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse to int and format
    final intValue = int.tryParse(cleanText) ?? 0;
    final formatted = _numberFormat.format(intValue);

    // Keep cursor at the end for simplicity (or calculate exact offset)
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Helper to get int from formatted string
  static int parseInt(String formatted) {
    if (formatted.isEmpty) return 0;
    return int.tryParse(formatted.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}
