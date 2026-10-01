import '../../domain/models/currency.dart';
import '../../domain/models/transaction.dart' as app_tx;
import '../../domain/repositories/transaction_repository.dart';
import '../database/database_helper.dart';

class SqfliteTransactionRepository implements TransactionRepository {
  final DatabaseHelper _dbHelper;

  SqfliteTransactionRepository(this._dbHelper);

  app_tx.Transaction _fromMap(Map<String, dynamic> map) {
    return app_tx.Transaction(
      id: map['id'] as String,
      accountId: map['account_id'] as String,
      type: app_tx.TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      amount: map['amount'] as int,
      currency: Currency.fromCode(map['currency_code'] as String),
      categoryId: map['category_id'] as String?,
      transferId: map['transfer_id'] as String?,
      linkedTransactionId: map['linked_transaction_id'] as String?,
      debtId: map['debt_id'] as String?,
      recurringId: map['recurring_id'] as String?,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> _toMap(app_tx.Transaction transaction) {
    return {
      'id': transaction.id,
      'account_id': transaction.accountId,
      'type': transaction.type.name,
      'amount': transaction.amount,
      'currency_code': transaction.currency.code,
      'category_id': transaction.categoryId,
      'transfer_id': transaction.transferId,
      'linked_transaction_id': transaction.linkedTransactionId,
      'debt_id': transaction.debtId,
      'recurring_id': transaction.recurringId,
      'date': transaction.date.toIso8601String(),
      'note': transaction.note,
      'created_at': transaction.createdAt.toIso8601String(),
      'updated_at': transaction.updatedAt.toIso8601String(),
    };
  }

  @override
  Future<void> createTransaction(app_tx.Transaction transaction) async {
    final db = await _dbHelper.database;
    await db.insert('transactions', _toMap(transaction));
  }

  @override
  Future<void> updateTransaction(app_tx.Transaction transaction) async {
    final db = await _dbHelper.database;
    await db.update(
      'transactions',
      _toMap(transaction),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final db = await _dbHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> createTransfer({
    required app_tx.Transaction transferOut,
    required app_tx.Transaction transferIn,
  }) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('transactions', _toMap(transferOut));
      await txn.insert('transactions', _toMap(transferIn));
    });
  }

  @override
  Future<void> deleteTransfer(String transferId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'transactions',
      where: 'transfer_id = ?',
      whereArgs: [transferId],
    );
  }

  @override
  Future<List<app_tx.Transaction>> getAllTransactions() async {
    final db = await _dbHelper.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<List<app_tx.Transaction>> searchTransactions({
    String? query,
    app_tx.TransactionType? type,
    String? accountId,
    String? categoryId,
    String? currencyCode,
    DateTime? startDate,
    DateTime? endDate,
    int? minAmount,
    int? maxAmount,
    bool? isDebtLinked,
    bool? isRecurringGenerated,
  }) async {
    final db = await _dbHelper.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClauses.add('note LIKE ?');
      whereArgs.add('%$query%');
    }
    if (type != null) {
      whereClauses.add('type = ?');
      whereArgs.add(type.name);
    }
    if (accountId != null) {
      whereClauses.add('account_id = ?');
      whereArgs.add(accountId);
    }
    if (categoryId != null) {
      whereClauses.add('category_id = ?');
      whereArgs.add(categoryId);
    }
    if (currencyCode != null) {
      whereClauses.add('currency_code = ?');
      whereArgs.add(currencyCode);
    }
    if (startDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }
    if (minAmount != null) {
      whereClauses.add('amount >= ?');
      whereArgs.add(minAmount);
    }
    if (maxAmount != null) {
      whereClauses.add('amount <= ?');
      whereArgs.add(maxAmount);
    }
    if (isDebtLinked != null) {
      if (isDebtLinked) {
        whereClauses.add('debt_id IS NOT NULL');
      } else {
        whereClauses.add('debt_id IS NULL');
      }
    }
    if (isRecurringGenerated != null) {
      if (isRecurringGenerated) {
        whereClauses.add('recurring_id IS NOT NULL');
      } else {
        whereClauses.add('recurring_id IS NULL');
      }
    }

    final whereString = whereClauses.isNotEmpty
        ? whereClauses.join(' AND ')
        : null;

    final result = await db.query(
      'transactions',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
    );

    return result.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<app_tx.Transaction?> getTransactionById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return _fromMap(result.first);
    }
    return null;
  }

  @override
  Future<List<app_tx.Transaction>> getTransactionsByAccountId(
    String accountId,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return result.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<List<app_tx.Transaction>> getTransactionsByDebtId(
    String debtId,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'debt_id = ?',
      whereArgs: [debtId],
      orderBy: 'date DESC',
    );
    return result.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<List<app_tx.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<Map<String, int>> getTotalIncomeByCurrency(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT currency_code, SUM(amount) as total
      FROM transactions
      WHERE type = 'income' AND date >= ? AND date <= ?
      GROUP BY currency_code
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    return _aggregateToMap(result);
  }

  @override
  Future<Map<String, int>> getTotalExpenseByCurrency(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT currency_code, SUM(amount) as total
      FROM transactions
      WHERE type = 'expense' AND date >= ? AND date <= ?
      GROUP BY currency_code
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    return _aggregateToMap(result);
  }

  @override
  Future<Map<String, int>> getSpendingByCategory(
    String categoryId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT currency_code, SUM(amount) as total
      FROM transactions
      WHERE type = 'expense' AND category_id = ? AND date >= ? AND date <= ?
      GROUP BY currency_code
    ''',
      [categoryId, start.toIso8601String(), end.toIso8601String()],
    );

    return _aggregateToMap(result);
  }

  Map<String, int> _aggregateToMap(List<Map<String, dynamic>> rows) {
    final map = <String, int>{};
    for (var row in rows) {
      final code = row['currency_code'] as String;
      final total = (row['total'] as num?)?.toInt() ?? 0;
      map[code] = total;
    }
    return map;
  }
}
