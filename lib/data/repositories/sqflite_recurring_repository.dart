import '../../domain/models/recurring_transaction.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/transaction.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../database/database_helper.dart';

class SqfliteRecurringTransactionRepository
    implements RecurringTransactionRepository {
  final DatabaseHelper _dbHelper;

  SqfliteRecurringTransactionRepository(this._dbHelper);

  RecurringTransaction _fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'] as String,
      amount: map['amount'] as int,
      currency: Currency.fromCode(map['currency_code'] as String),
      accountId: map['account_id'] as String,
      categoryId: map['category_id'] as String?,
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      note: map['note'] as String?,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      rule: RecurrenceRule.values.firstWhere(
        (e) => e.name == map['recurrence_rule'],
      ),
      nextOccurrence: DateTime.parse(map['next_occurrence'] as String),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> _toMap(RecurringTransaction r) {
    return {
      'id': r.id,
      'amount': r.amount,
      'currency_code': r.currency.code,
      'account_id': r.accountId,
      'category_id': r.categoryId,
      'type': r.type.name,
      'note': r.note,
      'start_date': r.startDate.toIso8601String(),
      'end_date': r.endDate?.toIso8601String(),
      'recurrence_rule': r.rule.name,
      'next_occurrence': r.nextOccurrence.toIso8601String(),
      'is_active': r.isActive ? 1 : 0,
      'created_at': r.createdAt.toIso8601String(),
      'updated_at': r.updatedAt.toIso8601String(),
    };
  }

  @override
  Future<void> createRecurringTransaction(RecurringTransaction r) async {
    final db = await _dbHelper.database;
    await db.insert('recurring_transactions', _toMap(r));
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    final db = await _dbHelper.database;
    await db.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<RecurringTransaction>> getActiveRecurringTransactions() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'recurring_transactions',
      where: 'is_active = 1',
    );
    return result.map((m) => _fromMap(m)).toList();
  }

  @override
  Future<List<RecurringTransaction>> getAllRecurringTransactions() async {
    final db = await _dbHelper.database;
    final result = await db.query('recurring_transactions');
    return result.map((m) => _fromMap(m)).toList();
  }

  @override
  Future<RecurringTransaction?> getRecurringTransactionById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return _fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> updateRecurringTransaction(RecurringTransaction r) async {
    final db = await _dbHelper.database;
    await db.update(
      'recurring_transactions',
      _toMap(r),
      where: 'id = ?',
      whereArgs: [r.id],
    );
  }
}
