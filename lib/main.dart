import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const WiaLogApp());
}

class WiaLogApp extends StatelessWidget {
  const WiaLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (context) => AuthBloc())],
      child: MaterialApp(
        title: 'WiaLog ERP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Aplicando a nossa cor primária centralizada no tema geral do app
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor:
              AppColors.background, // Fundo padrão padronizado
          useMaterial3: true,
          fontFamily: 'Segoe UI',
        ),
        home: const LoginPage(),
      ),
    );
  }
}
