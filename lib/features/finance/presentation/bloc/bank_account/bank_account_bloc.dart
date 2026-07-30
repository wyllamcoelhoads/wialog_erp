import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/bank_account_repository.dart';
import 'bank_account_event.dart';
import 'bank_account_state.dart';

class BankAccountBloc extends Bloc<BankAccountEvent, BankAccountState> {
  final BankAccountRepository repository;

  // Guarda o estado do filtro para recarregar a tela corretamente após salvar/excluir
  bool _lastIncludeInactive = false;

  BankAccountBloc(this.repository) : super(BankAccountInitial()) {
    // Buscar todas as contas
    on<LoadBankAccounts>((event, emit) async {
      emit(BankAccountLoading());
      _lastIncludeInactive = event
          .includeInactive; // Atualiza o estado do filtro as preferencias do usuário
      try {
        final accounts = await repository.getBankAccounts(
          includeInactive: event.includeInactive,
        );
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
        add(
          LoadBankAccounts(includeInactive: _lastIncludeInactive),
        ); // Recarrega a lista com o filtro atual
      } catch (e) {
        emit(BankAccountError('Erro ao salvar conta: $e'));
      }
    });

    on<UpdateBankAccount>((event, emit) async {
      emit(BankAccountLoading());
      try {
        await repository.updateBankAccount(event.account);
        add(LoadBankAccounts(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(BankAccountError('Erro ao atualizar conta: $e'));
      }
    });

    // Inativar (Soft Delete) uma conta
    on<DeleteBankAccount>((event, emit) async {
      emit(BankAccountLoading());
      try {
        await repository.deleteBankAccount(event.id);
        add(LoadBankAccounts(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(BankAccountError('Erro ao excluir conta: $e'));
      }
    });
  }
}
