import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/finance/domain/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;
  bool _lastIncludeInactive = false;

  UserBloc(this.repository) : super(UserInitial()) {
    on<LoadUsers>((event, emit) async {
      emit(UserLoading());
      _lastIncludeInactive = event.includeInactive;
      try {
        final list = await repository.getUsers(
          includeInactive: event.includeInactive,
        );
        emit(UserLoaded(list));
      } catch (e) {
        emit(UserError('Erro ao carregar usuários: $e'));
      }
    });

    on<AddUser>((event, emit) async {
      emit(UserLoading());
      try {
        await repository.createUser(event.user);
        add(LoadUsers(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(UserError('Erro ao salvar (E-mail já existe?): $e'));
      }
    });

    on<UpdateUser>((event, emit) async {
      emit(UserLoading());
      try {
        await repository.updateUser(event.user);
        add(LoadUsers(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(UserError('Erro ao atualizar: $e'));
      }
    });

    on<DeleteUser>((event, emit) async {
      emit(UserLoading());
      try {
        await repository.deleteUser(event.id);
        add(LoadUsers(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(UserError('Erro ao inativar: $e'));
      }
    });
  }
}
