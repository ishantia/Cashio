import '../models/debt.dart';

abstract class DebtRepository {
  Future<List<Debt>> getAllDebts();
  Future<Debt?> getDebtById(String id);
  Future<void> createDebt(Debt debt);
  Future<void> updateDebt(Debt debt);
  Future<void> deleteDebt(String id);
}
