import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/bank_account_repository.dart';
import 'bank_account_event.dart';
import 'bank_account_state.dart';

class BankAccountBloc extends Bloc<BankAccountEvent, BankAccountState> {
  final BankAccountRepository repository;

  BankAccountBloc(this.repository) : super(BankAccountInitial()) {
    // Buscar todas as contas
    on<LoadBankAccounts>((event, emit) async {
      emit(BankAccountLoading());
      try {
        final accounts = await repository.getBankAccounts();
        emit(BankAccountLoaded(accounts));
      } catch (e) {
        emit(BankAccountError('Erro ao buscar contas: $e'));
      }
    });

    // Salvar uma nova conta e recarregar a lista
    on<AddBankAccount>((event, emit) async {
      emit(BankAccountLoading());
      try {
        await repository.createBankAccount(event.account);
        add(LoadBankAccounts());
      } catch (e) {
        emit(BankAccountError('Erro ao salvar conta: $e'));
      }
    });

    // Inativar (Soft Delete) uma conta
    on<DeleteBankAccount>((event, emit) async {
      emit(BankAccountLoading());
      try {
        await repository.deleteBankAccount(event.id);
        add(LoadBankAccounts());
      } catch (e) {
        emit(BankAccountError('Erro ao excluir conta: $e'));
      }
    });
  }
}
