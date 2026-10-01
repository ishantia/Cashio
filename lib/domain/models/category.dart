import 'package:equatable/equatable.dart';

enum CategoryType { income, expense }

class Category extends Equatable {
  final String id;
  final String name;
  final CategoryType type;
  final String? parentId;
  final String? icon;
  final int? color;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.icon,
    this.color,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? parentId,
    String? icon,
    int? color,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    parentId,
    icon,
    color,
    isDefault,
    createdAt,
    updatedAt,
  ];
}
