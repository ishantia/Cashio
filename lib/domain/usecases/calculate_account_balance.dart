import '../models/account.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction.dart';

class CalculateAccountBalance {
  final TransactionRepository _transactionRepository;

  CalculateAccountBalance(this._transactionRepository);

  Future<int> execute(Account account) async {
    final transactions = await _transactionRepository
        .getTransactionsByAccountId(account.id);

    int balance = account.initialBalance;

    for (final tx in transactions) {
      if (tx.type == TransactionType.income ||
          tx.type == TransactionType.transferIn) {
        balance += tx.amount;
      } else if (tx.type == TransactionType.expense ||
          tx.type == TransactionType.transferOut) {
        balance -= tx.amount;
      }
    }

    return balance;
  }
}
