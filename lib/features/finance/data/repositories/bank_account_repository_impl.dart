import '../../domain/entities/bank_account_entity.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../datasources/bank_account_datasource.dart';
import '../models/bank_account_model.dart';

class BankAccountRepositoryImpl implements BankAccountRepository {
  final BankAccountDataSource dataSource;

  BankAccountRepositoryImpl(this.dataSource);

  @override
  Future<List<BankAccountEntity>> getBankAccounts({
    bool includeInactive = false,
  }) async {
    return await dataSource.getBankAccounts(includeInactive: includeInactive);
  }

  @override
  Future<BankAccountEntity> createBankAccount(BankAccountEntity account) async {
    // Convertendo a Entity que vem da tela para o Model que vai para o DataSource
    final model = BankAccountModel(
      id: account.id,
      description: account.description,
      bankId: account.bankId,
      bankName: account.bankName,
      agency: account.agency,
      accountNumber: account.accountNumber,
      accountType: account.accountType,
      initialBalance: account.initialBalance,
      currentBalance: account.currentBalance,
      isActive: account.isActive,
    );
    return await dataSource.createBankAccount(model);
  }

  @override
  Future<BankAccountEntity> updateBankAccount(BankAccountEntity account) async {
    final model = BankAccountModel(
      id: account.id,
      description: account.description,
      bankId: account.bankId,
      bankName: account.bankName,
      agency: account.agency,
      accountNumber: account.accountNumber,
      accountType: account.accountType,
      initialBalance: account.initialBalance,
      currentBalance: account.currentBalance,
      isActive: account.isActive,
    );
    return await dataSource.updateBankAccount(model);
  }

  @override
  Future<void> deleteBankAccount(int id) async {
    await dataSource.deleteBankAccount(id);
  }
}
