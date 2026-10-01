import 'package:equatable/equatable.dart';

import 'currency.dart';

enum TransactionType { income, expense, transferOut, transferIn }

class Transaction extends Equatable {
  final String id;
  final String accountId;
  final TransactionType type;

  /// Amount in the smallest unit of the currency
  final int amount;
  final Currency currency;

  final String? categoryId;

  /// Shared ID tying the two entries of a transfer together
  final String? transferId;

  /// References the counterpart transaction (e.g. transferIn id for a transferOut)
  final String? linkedTransactionId;

  final String? debtId;
  final String? recurringId;

  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.currency,
    this.categoryId,
    this.transferId,
    this.linkedTransactionId,
    this.debtId,
    this.recurringId,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    String? accountId,
    TransactionType? type,
    int? amount,
    Currency? currency,
    String? categoryId,
    String? transferId,
    String? linkedTransactionId,
    String? debtId,
    String? recurringId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      transferId: transferId ?? this.transferId,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
      debtId: debtId ?? this.debtId,
      recurringId: recurringId ?? this.recurringId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    accountId,
    type,
    amount,
    currency,
    categoryId,
    transferId,
    linkedTransactionId,
    debtId,
    recurringId,
    date,
    note,
    createdAt,
    updatedAt,
  ];
}
