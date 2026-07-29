import '../entities/bank_account_entity.dart';

abstract class BankAccountRepository {
  Future<List<BankAccountEntity>> getBankAccounts();
  Future<BankAccountEntity> createBankAccount(BankAccountEntity account);
  Future<void> deleteBankAccount(int id);
}
