import 'package:flutter_test/flutter_test.dart';
import 'package:cashio/domain/models/budget.dart';
import 'package:cashio/domain/models/currency.dart';
import 'package:cashio/data/repositories/sqflite_budget_repository.dart';
import 'package:cashio/data/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final path = await getDatabasesPath();
    await databaseFactory.deleteDatabase(join(path, 'cashio.db'));
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('budgets');
  });

  test('Budget enable/disable and delete', () async {
    final repo = SqfliteBudgetRepository(DatabaseHelper.instance);
    final budget = Budget(
      id: 'b1',
      categoryId: null,
      amount: 1000,
      currency: const Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        fractionalDigits: 2,
      ),
      period: BudgetPeriod.monthly,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await repo.createBudget(budget);

    var budgets = await repo.getAllBudgets();
    expect(budgets.first.isActive, true);

    // Disable
    await repo.updateBudget(budget.copyWith(isActive: false));
    budgets = await repo.getAllBudgets();
    expect(budgets.first.isActive, false);

    // Delete
    await repo.deleteBudget('b1');
    budgets = await repo.getAllBudgets();
    expect(budgets.isEmpty, true);
  });
}
