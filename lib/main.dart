import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart'; // NOVO IMPORT
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  // NOVO: Garante que os bindings do Flutter estão prontos antes de chamar código nativo
  WidgetsFlutterBinding.ensureInitialized();

  // NOVO: Inicializa o gerenciador de janelas
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600), // Tamanho mínimo para não quebrar o app
    center: true,
    title: 'WiaLog ERP',
  );

  // NOVO: Aplica as configurações e maximiza a tela antes de mostrar
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize(); // É AQUI QUE A MÁGICA ACONTECE!
  });

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
