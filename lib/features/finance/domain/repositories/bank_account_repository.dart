import '../entities/bank_account_entity.dart';

abstract class BankAccountRepository {
  Future<List<BankAccountEntity>> getBankAccounts({
    bool includeInactive = false,
  });
  Future<BankAccountEntity> createBankAccount(BankAccountEntity account);
  Future<BankAccountEntity> updateBankAccount(BankAccountEntity account);
  Future<void> deleteBankAccount(int id);
}
