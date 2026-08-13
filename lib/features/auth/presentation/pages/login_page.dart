import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wialog_erp/features/license/presentation/page/license_blocked_dialog.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../finance/presentation/pages/dashboard_page.dart';
import '../../../license/presentation/bloc/license_bloc.dart';
import '../../../license/presentation/bloc/license_event.dart';
import '../../../license/presentation/bloc/license_state.dart';

import '../bloc/auth_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 👇 NOVA FUNÇÃO: Centraliza a ação de login para ser chamada pelo botão e pelo "Enter"
  void _performLogin() {
    // Só tenta logar se não estiver carregando algo e o formulário for válido
    final authState = context.read<AuthBloc>().state;
    final licenseState = context.read<LicenseBloc>().state;

    if (authState is AuthLoading || licenseState is LicenseChecking) return;

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginSubmitted(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Lado Esquerdo: Identidade Visual (Brand)
          Expanded(
            flex: 5,
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_shipping, size: 100, color: Colors.white),
                    SizedBox(height: 24),
                    Text(
                      'WiaLog ERP',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gestão Inteligente de Frotas e Finanças',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lado Direito: Formulário
          Expanded(
            flex: 4,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: MultiBlocListener(
                    listeners: [
                      // LISTENER 1: Escuta o login (senha/email)
                      BlocListener<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                // 👇 CORREÇÃO DO ERRO DE DIGITAÇÃO: context.appColors.error
                                backgroundColor: context.appColors.error,
                              ),
                            );
                          } else if (state is AuthAuthenticated) {
                            // 👇 CORREÇÃO DO TEMA: Chamando a função que aceita a String do banco!
                            context.read<ThemeCubit>().setThemeFromPreference(
                              state.user.theme,
                            );
                            context.read<LicenseBloc>().add(CheckLicense());
                          }
                        },
                      ),

                      // LISTENER 2: Escuta a validação da Licença
                      BlocListener<LicenseBloc, LicenseState>(
                        listener: (context, state) {
                          if (state is LicenseValid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Acesso autorizado!'),
                                backgroundColor: context.appColors.success,
                              ),
                            );
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const DashboardPage(),
                              ),
                            );
                          } else if (state is LicenseBlocked) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) =>
                                  LicenseBlockedDialog(license: state.license),
                            );
                          } else if (state is LicenseError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Erro ao validar licença.'),
                                backgroundColor: context.appColors.error,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isCheckingLicense =
                            context.watch<LicenseBloc>().state
                                is LicenseChecking;
                        final isLoading =
                            state is AuthLoading || isCheckingLicense;

                        return Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Acesse sua conta',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),

                              // Campo de E-mail
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'E-mail',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                // 👇 ATALHO DE TECLADO: Se dar enter no email, vai pra senha
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira seu e-mail';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Campo de Senha
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                // 👇 A MÁGICA DO ENTER AQUI!
                                onFieldSubmitted: (_) => _performLogin(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira sua senha';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Botão Entrar
                              SizedBox(
                                height: 50,
                                child: FilledButton(
                                  onPressed: isLoading ? null : _performLogin,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Entrar',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
