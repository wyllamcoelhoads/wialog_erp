import 'package:equatable/equatable.dart';
import '../../../domain/entities/bank_account_entity.dart';

abstract class BankAccountEvent extends Equatable {
  const BankAccountEvent();
  @override
  List<Object?> get props => [];
}

class LoadBankAccounts extends BankAccountEvent {}

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
