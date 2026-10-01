import 'package:equatable/equatable.dart';

import 'currency.dart';

class Account extends Equatable {
  final String id;
  final String name;
  final Currency currency;
  final int initialBalance; // smallest currency unit
  final int currentBalance; // smallest currency unit
  final String? icon;
  final int? color;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.currency,
    required this.initialBalance,
    required this.currentBalance,
    this.icon,
    this.color,
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    String? id,
    String? name,
    Currency? currency,
    int? initialBalance,
    int? currentBalance,
    String? icon,
    int? color,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    currency,
    initialBalance,
    currentBalance,
    icon,
    color,
    isActive,
    notes,
    createdAt,
    updatedAt,
  ];
}
