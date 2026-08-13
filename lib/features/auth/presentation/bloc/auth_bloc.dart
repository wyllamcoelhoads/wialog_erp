import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/auth/domain/repositories/auth_repository.dart';
import 'package:wialog_erp/features/auth/presentation/bloc/auth_event.dart';
// NOVO: Importando o repositório

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository; // NOVO: Injeção do repositório

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);

    on<UpdateCurrentUserData>((event, emit) {
      // NOVO: Atualiza os dados do usuário na memória (Sessão)
      if (state is AuthAuthenticated) {
        emit(AuthAuthenticated(user: event.updatedUser));
      }
    });
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
        emit(
          AuthAuthenticated(user: user),
        ); // NOVO: Passando o usuário completo para o estado
      }
    } catch (e) {
      emit(AuthError(message: 'Erro de conexão com o banco de dados.'));
    }
  }
}
