import '../../../../core/database/database_connection.dart';
import '../models/bank_account_model.dart';

abstract class BankAccountDataSource {
  Future<List<BankAccountModel>> getBankAccounts();
  Future<BankAccountModel> createBankAccount(BankAccountModel account);
  Future<BankAccountModel> updateBankAccount(BankAccountModel account);
  Future<void> deleteBankAccount(int id);
}

class BankAccountPostgresDataSource implements BankAccountDataSource {
  final DatabaseConnection dbConnection;
  BankAccountPostgresDataSource(this.dbConnection);

  @override
  Future<List<BankAccountModel>> getBankAccounts() async {
    const sql = '''
      SELECT ba.*, b.name as bank_name 
      FROM bank_accounts ba
      JOIN banks b ON ba.bank_id = b.id
      WHERE ba.is_active = true
      ORDER BY ba.description ASC
    ''';
    final result = await dbConnection.query(sql);
    return result
        .map((row) => BankAccountModel.fromMap(row.toColumnMap()))
        .toList();
  }

  @override
  Future<BankAccountModel> createBankAccount(BankAccountModel account) async {
    const sql = '''
      INSERT INTO bank_accounts (description, bank_id, agency, account_number, account_type, initial_balance, current_balance)
      VALUES (@description, @bank_id, @agency, @account_number, @account_type, @initial_balance, @initial_balance)
      RETURNING *;
    ''';

    // NOVO: Removemos as chaves que não estão descritas no SQL acima
    final params = account.toMap();
    params.remove('id');
    params.remove('current_balance');
    params.remove('is_active');

    final result = await dbConnection.query(sql, params);
    return BankAccountModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<BankAccountModel> updateBankAccount(BankAccountModel account) async {
    const sql = '''
      UPDATE bank_accounts 
      SET description = @description,
          bank_id = @bank_id,
          agency = @agency,
          account_number = @account_number,
          account_type = @account_type
      WHERE id = @id;
    ''';

    // Atualizamos apenas os dados editáveis (não mexemos em saldo aqui)
    final params = {
      'id': account.id,
      'description': account.description,
      'bank_id': account.bankId,
      'agency': account.agency,
      'account_number': account.accountNumber,
      'account_type': account.accountType.name,
    };

    await dbConnection.query(sql, params);
    return account; // Retornamos a conta atualizada
  }

  @override
  Future<void> deleteBankAccount(int id) async {
    await dbConnection.query(
      'UPDATE bank_accounts SET is_active = false WHERE id = @id',
      {'id': id},
    );
  }
}
