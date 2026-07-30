import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// NOVO: Importando o repositório
import '../../domain/repositories/auth_repository.dart';

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
  final AuthRepository repository; // NOVO: Injeção do repositório

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Bate no banco de dados real
      final user = await repository.authenticate(event.email, event.password);

      if (user == null) {
        // Se retornou nulo, é porque e-mail ou senha não bateram
        emit(const AuthError(message: 'E-mail ou senha inválidos.'));
      } else if (!user.isActive) {
        // Se achou o usuário, mas isActive é false (Bloqueado)
        emit(
          const AuthError(
            message: 'Seu acesso está bloqueado. Contate o administrador.',
          ),
        );
      } else {
        // Se passou em tudo, logado com sucesso!
        emit(AuthAuthenticated(role: user.roleName ?? 'Desconhecido'));
      }
    } catch (e) {
      emit(AuthError(message: 'Erro de conexão com o banco de dados.'));
    }
  }
}
