import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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

// No padrão BLoC convencional, isso ficaria em auth_state.dart
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String role; // ex: Admin, Fiscal, Financeiro

  const AuthAuthenticated({required this.role});

  @override
  List<Object> get props => [role];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Simulação de delay de rede/banco de dados
      await Future.delayed(const Duration(seconds: 2));

      // Validação fake para o MVP
      if (event.email == 'admin@wialog.com' && event.password == '123456') {
        emit(const AuthAuthenticated(role: 'Admin'));
      } else {
        emit(const AuthError(message: 'E-mail ou senha inválidos.'));
      }
    } catch (e) {
      emit(const AuthError(message: 'Erro ao tentar realizar o login.'));
    }
  }
}
