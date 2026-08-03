import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/core/theme/theme_cubit.dart';
import 'package:wialog_erp/features/auth/presentation/bloc/auth_event.dart';
import 'package:wialog_erp/features/finance/domain/entities/user_entity.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/user/user_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/user/user_event.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Busca os dados do usuário logado na memória do AuthBloc
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Center(child: Text('Erro: Sessão não encontrada.'));
    }

    final currentUser = authState.user;
    final roleName = currentUser.roleName ?? 'Desconhecido';
    final isAdmin = roleName.toLowerCase().contains('admin');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Permissões e Preferências',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gerencie a aparência do sistema e consulte seus níveis de acesso.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // CARD 1: PREFERÊNCIAS VISUAIS (TEMA)
            Card(
              color: Theme.of(context).cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: const Color(0xFF9E9E9E).withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferências Visuais',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        context.watch<ThemeCubit>().isDark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        size: 32,
                        color: context.appColors.primary,
                      ),
                      title: Text(
                        'Modo Escuro (Dark Mode)',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        'Altera as cores do sistema para reduzir o cansaço visual.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: Switch(
                        value: context.watch<ThemeCubit>().isDark,
                        activeThumbColor: context.appColors.primary,
                        onChanged: (val) {
                          // 1. Troca a cor na tela imediatamente
                          context.read<ThemeCubit>().toggleTheme();

                          // 2. Salva no banco de dados para os próximos logins!
                          final updatedUser = UserEntity(
                            id: currentUser.id,
                            employeeId: currentUser.employeeId,
                            email: currentUser.email,
                            password: currentUser.password,
                            roleId: currentUser.roleId,
                            isActive: currentUser.isActive,
                            theme: val ? 'dark' : 'light',
                            customPermissions: currentUser.customPermissions,
                          );
                          // Envia o update silenciosamente para o DB
                          context.read<UserBloc>().add(UpdateUser(updatedUser));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // CARD 2: PERMISSÕES DE ACESSO
            Card(
              color: Theme.of(context).cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: const Color(0xFF9E9E9E).withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meus Acessos e Permissões',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.shield,
                          color: context.appColors.success,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seu Cargo Base:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              roleName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (isAdmin)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.appColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              color: context.appColors.primary,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Você possui o perfil de Administrador. Suas permissões não podem ser restritas, você tem acesso irrestrito a todas as configurações de negócio da plataforma.',
                                style: TextStyle(
                                  color: context.appColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.appColors.warning.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_person,
                              color: context.appColors.warning,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'As suas permissões foram herdadas do seu cargo. Se houver alguma configuração avançada liberada apenas para sua conta, ela irá sobrescrever as regras do cargo.',
                                style: TextStyle(
                                  color: context.appColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
