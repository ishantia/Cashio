import '../models/debt.dart';
import '../models/transaction.dart';
import '../models/currency.dart';
import '../repositories/transaction_repository.dart';

class CalculateDebtBalance {
  final TransactionRepository _transactionRepository;

  CalculateDebtBalance(this._transactionRepository);

  Future<int> execute(Debt debt) async {
    final debtTxs = await _transactionRepository.getTransactionsByDebtId(
      debt.id,
    );

    int appliedAmount = 0;

    for (final tx in debtTxs) {
      int txApplied = 0;

      // Calculate how much this transaction applies to the debt
      if (tx.currency == debt.currency) {
        txApplied = tx.amount;
      } else if (tx.currency == Currency.toman &&
          debt.currency == Currency.irr) {
        txApplied = tx.amount * 10;
      } else if (tx.currency == Currency.irr &&
          debt.currency == Currency.toman) {
        txApplied = (tx.amount / 10).round();
      } else {
        txApplied = 0;
      }

      // If I owe money, expenses increase the applied amount (paying it off).
      // If someone owes me, incomes increase the applied amount (they paid me back).
      if (debt.direction == DebtDirection.iOwe) {
        if (tx.type == TransactionType.expense ||
            tx.type == TransactionType.transferOut) {
          appliedAmount += txApplied;
        } else if (tx.type == TransactionType.income ||
            tx.type == TransactionType.transferIn) {
          appliedAmount -= txApplied; // Refund / overpayment correction
        }
      } else {
        // owedToMe
        if (tx.type == TransactionType.income ||
            tx.type == TransactionType.transferIn) {
          appliedAmount += txApplied;
        } else if (tx.type == TransactionType.expense ||
            tx.type == TransactionType.transferOut) {
          appliedAmount -= txApplied; // Refund / overpayment correction
        }
      }
    }

    final remaining = debt.amount - appliedAmount;
    return remaining; // Can be negative if overpaid
  }
}
