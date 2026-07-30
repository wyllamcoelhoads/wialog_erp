import 'package:equatable/equatable.dart';
import '../../../domain/entities/employee_entity.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();
  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {
  final bool includeInactive;
  const LoadEmployees({this.includeInactive = false});
  @override
  List<Object?> get props => [includeInactive];
}

class AddEmployee extends EmployeeEvent {
  final EmployeeEntity employee;
  const AddEmployee(this.employee);
  @override
  List<Object?> get props => [employee];
}

class UpdateEmployee extends EmployeeEvent {
  final EmployeeEntity employee;
  const UpdateEmployee(this.employee);
  @override
  List<Object?> get props => [employee];
}

class DeleteEmployee extends EmployeeEvent {
  final int id;
  const DeleteEmployee(this.id);
  @override
  List<Object?> get props => [id];
}
