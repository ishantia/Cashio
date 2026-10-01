import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../database/database_helper.dart';

class SqfliteCategoryRepository implements CategoryRepository {
  final DatabaseHelper _dbHelper;

  SqfliteCategoryRepository(this._dbHelper);

  Category _fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: CategoryType.values.firstWhere((e) => e.name == map['type']),
      parentId: map['parent_id'] as String?,
      icon: map['icon'] as String?,
      color: map['color'] as int?,
      isDefault: (map['is_default'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> _toMap(Category category) {
    return {
      'id': category.id,
      'name': category.name,
      'type': category.type.name,
      'parent_id': category.parentId,
      'icon': category.icon,
      'color': category.color,
      'is_default': category.isDefault ? 1 : 0,
      'created_at': category.createdAt.toIso8601String(),
      'updated_at': category.updatedAt.toIso8601String(),
    };
  }

  @override
  Future<void> createCategory(Category category) async {
    final db = await _dbHelper.database;
    await db.insert('categories', _toMap(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'name ASC',
    );
    return result.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return _fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> updateCategory(Category category) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      _toMap(category),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> initializeDefaultCategories() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    if (count != null && count > 0) return;

    final now = DateTime.now();
    final defaultCategories = [
      Category(
        id: const Uuid().v4(),
        name: 'Food',
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: const Uuid().v4(),
        name: 'Transport',
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: const Uuid().v4(),
        name: 'Shopping',
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: const Uuid().v4(),
        name: 'Bills',
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: const Uuid().v4(),
        name: 'Salary',
        type: CategoryType.income,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: const Uuid().v4(),
        name: 'Freelance',
        type: CategoryType.income,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final batch = db.batch();
    for (final cat in defaultCategories) {
      batch.insert('categories', _toMap(cat));
    }
    await batch.commit(noResult: true);
  }
}
