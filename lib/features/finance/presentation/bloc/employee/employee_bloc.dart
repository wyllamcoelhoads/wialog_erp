import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/employee_repository.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository repository;
  bool _lastIncludeInactive = false;

  EmployeeBloc(this.repository) : super(EmployeeInitial()) {
    on<LoadEmployees>((event, emit) async {
      emit(EmployeeLoading());
      _lastIncludeInactive = event.includeInactive;
      try {
        final list = await repository.getEmployees(
          includeInactive: event.includeInactive,
        );
        emit(EmployeeLoaded(list));
      } catch (e) {
        emit(EmployeeError('Erro ao carregar funcionários: $e'));
      }
    });

    on<AddEmployee>((event, emit) async {
      emit(EmployeeLoading());
      try {
        await repository.createEmployee(event.employee);
        add(LoadEmployees(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(EmployeeError('Erro ao salvar: $e'));
      }
    });

    on<UpdateEmployee>((event, emit) async {
      emit(EmployeeLoading());
      try {
        await repository.updateEmployee(event.employee);
        add(LoadEmployees(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(EmployeeError('Erro ao atualizar: $e'));
      }
    });

    on<DeleteEmployee>((event, emit) async {
      emit(EmployeeLoading());
      try {
        await repository.deleteEmployee(event.id);
        add(LoadEmployees(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(EmployeeError('Erro ao excluir: $e'));
      }
    });
  }
}
