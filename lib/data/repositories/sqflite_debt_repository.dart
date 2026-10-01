import '../../domain/models/debt.dart';
import '../../domain/models/currency.dart';
import '../../domain/repositories/debt_repository.dart';
import '../database/database_helper.dart';

class SqfliteDebtRepository implements DebtRepository {
  final DatabaseHelper _dbHelper;

  SqfliteDebtRepository(this._dbHelper);

  Debt _fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as String,
      personName: map['person_name'] as String,
      direction: DebtDirection.values.firstWhere(
        (e) => e.name == map['direction'],
      ),
      amount: map['amount'] as int,
      currency: Currency.fromCode(map['currency_code'] as String),
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      note: map['note'] as String?,
      status: DebtStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> _toMap(Debt debt) {
    return {
      'id': debt.id,
      'person_name': debt.personName,
      'direction': debt.direction.name,
      'amount': debt.amount,
      'currency_code': debt.currency.code,
      'due_date': debt.dueDate?.toIso8601String(),
      'note': debt.note,
      'status': debt.status.name,
      'created_at': debt.createdAt.toIso8601String(),
      'updated_at': debt.updatedAt.toIso8601String(),
    };
  }

  @override
  Future<void> createDebt(Debt debt) async {
    final db = await _dbHelper.database;
    await db.insert('debts', _toMap(debt));
  }

  @override
  Future<void> deleteDebt(String id) async {
    final db = await _dbHelper.database;
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Debt>> getAllDebts() async {
    final db = await _dbHelper.database;
    final result = await db.query('debts', orderBy: 'created_at DESC');
    return result.map((m) => _fromMap(m)).toList();
  }

  @override
  Future<Debt?> getDebtById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('debts', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return _fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    final db = await _dbHelper.database;
    await db.update(
      'debts',
      _toMap(debt),
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }
}
