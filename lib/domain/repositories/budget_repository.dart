import '../models/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<Budget?> getBudgetById(String id);
  Future<void> createBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
}
