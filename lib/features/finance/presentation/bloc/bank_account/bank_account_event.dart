import 'package:equatable/equatable.dart';
import 'package:wialog_erp/features/finance/domain/entities/bank_account_entity.dart';

abstract class BankAccountEvent extends Equatable {
  const BankAccountEvent();
  @override
  List<Object?> get props => [];
}

class LoadBankAccounts extends BankAccountEvent {
  final bool includeInactive;
  const LoadBankAccounts({
    this.includeInactive = false,
  }); // Adicionei o parâmetro includeInactive com valor padrão false

  @override
  List<Object?> get props => [includeInactive];
}

class AddBankAccount extends BankAccountEvent {
  final BankAccountEntity account;
  const AddBankAccount(this.account);
  @override
  List<Object?> get props => [account];
}

class UpdateBankAccount extends BankAccountEvent {
  final BankAccountEntity account;
  const UpdateBankAccount(this.account);
  @override
  List<Object?> get props => [account];
}

class DeleteBankAccount extends BankAccountEvent {
  final int id;
  const DeleteBankAccount(this.id);
  @override
  List<Object?> get props => [id];
}
