import 'package:equatable/equatable.dart';
import 'package:wialog_erp/features/role/domain/entities/role_entity.dart';

abstract class RoleEvent extends Equatable {
  const RoleEvent();
  @override
  List<Object?> get props => [];
}

class LoadRoles extends RoleEvent {
  final bool includeInactive;
  const LoadRoles({this.includeInactive = false});
  @override
  List<Object?> get props => [includeInactive];
}

class AddRole extends RoleEvent {
  final RoleEntity role;
  const AddRole(this.role);
  @override
  List<Object?> get props => [role];
}

class UpdateRole extends RoleEvent {
  final RoleEntity role;
  const UpdateRole(this.role);
  @override
  List<Object?> get props => [role];
}

class DeleteRole extends RoleEvent {
  final int id;
  const DeleteRole(this.id);
  @override
  List<Object?> get props => [id];
}
