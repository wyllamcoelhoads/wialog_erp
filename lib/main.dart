import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      providers: [
        // Injetando o AuthBloc na raiz para estar disponível em toda a aplicação
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
      ],
      child: MaterialApp(
        title: 'WiaLog ERP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A), // Azul escuro corporativo
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Segoe UI', // Fonte padrão confortável para Windows
        ),
        home: const LoginPage(),
      ),
    );
  }
}
