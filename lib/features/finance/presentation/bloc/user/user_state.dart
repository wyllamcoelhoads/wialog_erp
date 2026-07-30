import 'package:equatable/equatable.dart';
import 'package:wialog_erp/features/finance/domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserEntity> users;
  final List<UserEntity>
  allUsers; // NOVO: Guarda a lista completa (com inativos) para validações

  const UserLoaded(this.users, {this.allUsers = const []});

  @override
  List<Object?> get props => [users, allUsers];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object?> get props => [message];
}
