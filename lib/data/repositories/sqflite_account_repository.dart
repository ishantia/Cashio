import '../../domain/models/account.dart';
import '../../domain/models/currency.dart';
import '../../domain/repositories/account_repository.dart';
import '../database/database_helper.dart';

class SqfliteAccountRepository implements AccountRepository {
  final DatabaseHelper _dbHelper;

  SqfliteAccountRepository(this._dbHelper);

  Account _fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      currency: Currency.fromCode(map['currency_code'] as String),
      initialBalance: map['initial_balance'] as int,
      currentBalance: map['current_balance'] as int,
      icon: map['icon'] as String?,
      color: map['color'] as int?,
      isActive: (map['is_active'] as int) == 1,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> _toMap(Account account) {
    return {
      'id': account.id,
      'name': account.name,
      'currency_code': account.currency.code,
      'initial_balance': account.initialBalance,
      'current_balance': account.currentBalance,
      'icon': account.icon,
      'color': account.color,
      'is_active': account.isActive ? 1 : 0,
      'notes': account.notes,
      'created_at': account.createdAt.toIso8601String(),
      'updated_at': account.updatedAt.toIso8601String(),
    };
  }

  @override
  Future<void> createAccount(Account account) async {
    final db = await _dbHelper.database;
    await db.insert('accounts', _toMap(account));
  }

  @override
  Future<void> deleteAccount(String id) async {
    final db = await _dbHelper.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return _fromMap(result.first);
    }
    return null;
  }

  @override
  Future<List<Account>> getAllAccounts() async {
    final db = await _dbHelper.database;
    final result = await db.query('accounts', orderBy: 'created_at ASC');
    return result.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<void> updateAccount(Account account) async {
    final db = await _dbHelper.database;
    await db.update(
      'accounts',
      _toMap(account),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }
}
