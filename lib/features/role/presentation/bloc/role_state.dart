import 'package:equatable/equatable.dart';
import 'package:wialog_erp/features/role/domain/entities/role_entity.dart';

abstract class RoleState extends Equatable {
  const RoleState();
  @override
  List<Object?> get props => [];
}

class RoleInitial extends RoleState {}

class RoleLoading extends RoleState {}

class RoleLoaded extends RoleState {
  final List<RoleEntity> roles;
  const RoleLoaded(this.roles);
  @override
  List<Object?> get props => [roles];
}

class RoleError extends RoleState {
  final String message;
  const RoleError(this.message);
  @override
  List<Object?> get props => [message];
}
