import 'package:sqflite/sqflite.dart';

import '../../domain/models/budget.dart';
import '../../domain/models/currency.dart';
import '../../domain/repositories/budget_repository.dart';
import '../database/database_helper.dart';

class SqfliteBudgetRepository implements BudgetRepository {
  final DatabaseHelper _dbHelper;

  SqfliteBudgetRepository(this._dbHelper);

  @override
  Future<void> createBudget(Budget budget) async {
    final db = await _dbHelper.database;
    await db.insert('budgets', {
      'id': budget.id,
      'category_id': budget.categoryId,
      'amount': budget.amount,
      'currency_code': budget.currency.code,
      'period': budget.period.name,
      'is_active': budget.isActive ? 1 : 0,
      'created_at': budget.createdAt.toIso8601String(),
      'updated_at': budget.updatedAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<Budget>> getAllBudgets() async {
    final db = await _dbHelper.database;
    final result = await db.query('budgets');
    return result.map((m) => _fromMap(m)).toList();
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('budgets', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return _fromMap(result.first);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final db = await _dbHelper.database;
    await db.update(
      'budgets',
      {
        'category_id': budget.categoryId,
        'amount': budget.amount,
        'currency_code': budget.currency.code,
        'period': budget.period.name,
        'is_active': budget.isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  @override
  Future<void> deleteBudget(String id) async {
    final db = await _dbHelper.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Budget _fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      categoryId: map['category_id'] as String?,
      amount: map['amount'] as int,
      currency: Currency.fromCode(map['currency_code'] as String),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
