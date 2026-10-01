import 'package:equatable/equatable.dart';

import 'currency.dart';

enum DebtDirection { iOwe, owedToMe }

enum DebtStatus { active, paid }

class Debt extends Equatable {
  final String id;
  final String personName;
  final DebtDirection direction;
  final int amount; // Original debt amount
  final Currency currency;
  final DateTime? dueDate;
  final String? note;
  final DebtStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Debt({
    required this.id,
    required this.personName,
    required this.direction,
    required this.amount,
    required this.currency,
    this.dueDate,
    this.note,
    this.status = DebtStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  Debt copyWith({
    String? id,
    String? personName,
    DebtDirection? direction,
    int? amount,
    Currency? currency,
    DateTime? dueDate,
    String? note,
    DebtStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    personName,
    direction,
    amount,
    currency,
    dueDate,
    note,
    status,
    createdAt,
    updatedAt,
  ];
}
