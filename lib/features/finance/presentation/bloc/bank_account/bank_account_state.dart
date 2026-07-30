import 'package:equatable/equatable.dart';
import '../../../domain/entities/bank_account_entity.dart';

abstract class BankAccountState extends Equatable {
  const BankAccountState();
  @override
  List<Object?> get props => [];
}

class BankAccountInitial extends BankAccountState {}

class BankAccountLoading extends BankAccountState {}

class BankAccountLoaded extends BankAccountState {
  final List<BankAccountEntity> accounts;
  const BankAccountLoaded(this.accounts);
  @override
  List<Object?> get props => [accounts];
}

class BankAccountError extends BankAccountState {
  final String message;
  const BankAccountError(this.message);
  @override
  List<Object?> get props => [message];
}
