import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                                backgroundColor: context.appColors.error,
                              ),
                            );
                          } else if (state is AuthAuthenticated) {
                            // Senha bateu! Configura o tema do usuário e CHAMA A LICENÇA
                            context.read<ThemeCubit>().setTheme(
                              state.user.theme as ThemeMode,
                            );
                            context.read<LicenseBloc>().add(CheckLicense());
                          }
                        },
                      ),

                      // LISTENER 2: Escuta a validação da Licença
                      BlocListener<LicenseBloc, LicenseState>(
                        listener: (context, state) {
                          if (state is LicenseValid) {
                            // Licença OK! Agora sim vai pro sistema.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Acesso autorizado!'),
                                backgroundColor: context.appColors.success,
                              ),
                            );
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const DashboardPage(),
                              ),
                            );
                          } else if (state is LicenseBlocked) {
                            // Licença Bloqueada/Vencida! Abre o Pop-up.
                            showDialog(
                              context: context,
                              barrierDismissible:
                                  false, // Prende o usuário aqui
                              builder: (ctx) =>
                                  LicenseBlockedDialog(license: state.license),
                            );
                          } else if (state is LicenseError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao validar licença.'),
                                backgroundColor: context.appColors.error,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        // <- Aqui a variável chama 'state' (minúsculo)
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
                                  // Bloqueia o botão se estiver carregando
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context.read<AuthBloc>().add(
                                              LoginSubmitted(
                                                email: _emailController.text,
                                                password:
                                                    _passwordController.text,
                                              ),
                                            );
                                          }
                                        },
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
