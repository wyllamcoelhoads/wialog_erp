import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/core/theme/app_colors.dart';
import 'package:wialog_erp/core/theme/theme_cubit.dart';
import 'package:wialog_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wialog_erp/features/auth/presentation/bloc/auth_event.dart';
import 'package:wialog_erp/features/finance/domain/entities/user_entity.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/user/user_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/user/user_event.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late String _selectedTheme;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Pega o tema atual do usuário logado ao abrir a tela
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _selectedTheme = authState.user.theme;
    } else {
      _selectedTheme = 'light';
    }
  }

  void _savePreferences() {
    setState(() => _isLoading = true);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final currentUser = authState.user;

      // 1. Cria a cópia do usuário com o novo tema
      final updatedUser = UserEntity(
        id: currentUser.id,
        employeeId: currentUser.employeeId,
        employeeName: currentUser.employeeName,
        email: currentUser.email,
        password: currentUser.password,
        roleId: currentUser.roleId,
        roleName: currentUser.roleName,
        isActive: currentUser.isActive,
        customPermissions: currentUser.customPermissions,
        theme: _selectedTheme, // AQUI ESTÁ A MUDANÇA PRO BANCO
      );

      // 2. Manda pro banco de dados (PostgreSQL) usando o UserBloc
      context.read<UserBloc>().add(UpdateUser(updatedUser));

      // 3. Atualiza a sessão atual na memória do app (AuthBloc)
      context.read<AuthBloc>().add(UpdateCurrentUserData(updatedUser));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preferências salvas com sucesso!'),
          backgroundColor: context.appColors.success,
        ),
      );

      setState(() {
        _isLoading = false;
        _hasChanges = false; // Tira o aviso de alterações pendentes
      });
    }
  }

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
      backgroundColor: context.appColors.background,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CABEÇALHO COM BOTÃO DE SALVAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permissões e Preferências',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gerencie a aparência do sistema e consulte seus acessos.',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.appColors.textMuted,
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: (_hasChanges && !_isLoading)
                      ? _savePreferences
                      : null,
                  icon: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: context.appColors.textTitle,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.save, color: context.appColors.textTitle),
                  label: Text(
                    _isLoading ? 'Salvando...' : 'Salvar Preferências',
                    style: TextStyle(
                      color: context.appColors.textTitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.appColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // CARD 1: PREFERÊNCIAS VISUAIS (TEMA)
            Card(
              color: context.appColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: context.appColors.border.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Preferências Visuais',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.appColors.textTitle,
                          ),
                        ),
                        if (_hasChanges) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.appColors.warning.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Alterações não salvas',
                              style: TextStyle(
                                color: context.appColors.warning,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _selectedTheme == 'dark'
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        size: 32,
                        color: context.appColors.primary,
                      ),
                      title: Text(
                        'Modo Escuro (Dark Mode)',
                        style: TextStyle(color: context.appColors.textBody),
                      ),
                      subtitle: Text(
                        'Altera as cores do sistema para reduzir o cansaço visual.',
                        style: TextStyle(color: context.appColors.textMuted),
                      ),
                      trailing: Switch(
                        value: _selectedTheme == 'dark',
                        activeThumbColor: context.appColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _selectedTheme = val ? 'dark' : 'light';
                            _hasChanges = true; // Libera o botão de salvar
                          });
                          // Muda na tela na hora para o usuário ver como fica (Pré-visualização)
                          context.read<ThemeCubit>().setThemeFromPreference(
                            _selectedTheme,
                          );
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
              color: context.appColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: context.appColors.border.withValues(alpha: 0.3),
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
                        color: context.appColors.textTitle,
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
                            Text(
                              'Seu Cargo Base:',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.appColors.textMuted,
                              ),
                            ),
                            Text(
                              roleName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: context.appColors.textTitle,
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
                            const SizedBox(width: 16),
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
