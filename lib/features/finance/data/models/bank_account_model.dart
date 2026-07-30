import '../../domain/entities/bank_account_entity.dart';

class BankAccountModel extends BankAccountEntity {
  BankAccountModel({
    required super.id,
    required super.description,
    required super.bankId,
    required super.bankName,
    super.agency,
    super.accountNumber,
    required super.accountType,
    super.initialBalance,
    super.currentBalance,
    super.isActive,
  });

  factory BankAccountModel.fromMap(Map<String, dynamic> map) {
    return BankAccountModel(
      id: map['id'],
      description: map['description'],
      bankId: map['bank_id'],
      bankName: map['bank_name'] ?? 'Desconhecido',
      agency: map['agency'],
      accountNumber: map['account_number'],
      accountType: AccountType.values.firstWhere(
        (e) => e.name == map['account_type'],
        orElse: () => AccountType.cash,
      ),
      initialBalance: double.parse(map['initial_balance'].toString()),
      currentBalance: double.parse(map['current_balance'].toString()),
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'bank_id': bankId,
      'agency': agency,
      'account_number': accountNumber,
      'account_type': accountType.name,
      'initial_balance': initialBalance,
      'current_balance': currentBalance,
      'is_active': isActive,
    };
  }
}
