import 'package:equatable/equatable.dart';

import 'currency.dart';

enum BudgetPeriod { monthly, yearly, custom }

class Budget extends Equatable {
  final String id;
  final String? categoryId; // If null, global budget
  final int amount;
  final Currency currency;
  final BudgetPeriod period;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.currency,
    required this.period,
    this.isActive = true,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Budget copyWith({
    String? id,
    String? categoryId,
    int? amount,
    Currency? currency,
    BudgetPeriod? period,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    amount,
    currency,
    period,
    isActive,
    startDate,
    endDate,
    createdAt,
    updatedAt,
  ];
}
