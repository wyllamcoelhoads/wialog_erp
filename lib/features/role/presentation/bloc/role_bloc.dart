import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/role/domain/repositories/role_repository.dart';
import 'role_event.dart';
import 'role_state.dart';

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final RoleRepository repository;
  bool _lastIncludeInactive = false;

  RoleBloc(this.repository) : super(RoleInitial()) {
    on<LoadRoles>((event, emit) async {
      emit(RoleLoading());
      _lastIncludeInactive = event.includeInactive;
      try {
        final list = await repository.getRoles(
          includeInactive: event.includeInactive,
        );
        emit(RoleLoaded(list));
      } catch (e) {
        emit(RoleError('Erro ao carregar cargos: $e'));
      }
    });

    on<AddRole>((event, emit) async {
      emit(RoleLoading());
      try {
        await repository.createRole(event.role);
        add(LoadRoles(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(RoleError('Erro ao salvar cargo: $e'));
      }
    });

    on<UpdateRole>((event, emit) async {
      emit(RoleLoading());
      try {
        await repository.updateRole(event.role);
        add(LoadRoles(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(RoleError('Erro ao atualizar cargo: $e'));
      }
    });

    on<DeleteRole>((event, emit) async {
      emit(RoleLoading());
      try {
        await repository.deleteRole(event.id);
        add(LoadRoles(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(RoleError('Erro ao excluir cargo: $e'));
      }
    });
  }
}
