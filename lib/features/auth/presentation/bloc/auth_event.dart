import 'package:equatable/equatable.dart';
import 'package:wialog_erp/features/finance/domain/entities/user_entity.dart';

// No padrão BLoC convencional, isso ficaria em auth_event.dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

// Atualiza os dados do usuário na memória (Sessão)
class UpdateCurrentUserData extends AuthEvent {
  final UserEntity updatedUser;

  const UpdateCurrentUserData(this.updatedUser);

  @override
  List<Object> get props => [updatedUser];
}

// No padrão BLoC convencional, isso ficaria em auth_state.dart
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user; // Alterado para armazenar o usuário completo

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
