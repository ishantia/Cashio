import 'package:equatable/equatable.dart';

import 'currency.dart';
import 'transaction.dart';

enum RecurrenceRule { daily, weekly, monthly, yearly }

class RecurringTransaction extends Equatable {
  final String id;
  final int amount;
  final Currency currency;
  final String accountId;
  final String? categoryId;
  final TransactionType type;
  final String? note;
  final DateTime startDate;
  final DateTime? endDate;
  final RecurrenceRule rule;
  final DateTime nextOccurrence;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringTransaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.accountId,
    this.categoryId,
    required this.type,
    this.note,
    required this.startDate,
    this.endDate,
    required this.rule,
    required this.nextOccurrence,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringTransaction copyWith({
    String? id,
    int? amount,
    Currency? currency,
    String? accountId,
    String? categoryId,
    TransactionType? type,
    String? note,
    DateTime? startDate,
    DateTime? endDate,
    RecurrenceRule? rule,
    DateTime? nextOccurrence,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      note: note ?? this.note,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rule: rule ?? this.rule,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    currency,
    accountId,
    categoryId,
    type,
    note,
    startDate,
    endDate,
    rule,
    nextOccurrence,
    isActive,
    createdAt,
    updatedAt,
  ];
}
