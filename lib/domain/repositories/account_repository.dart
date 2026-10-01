import '../models/account.dart';

abstract class AccountRepository {
  Future<List<Account>> getAllAccounts();
  Future<Account?> getAccountById(String id);
  Future<void> createAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
}
