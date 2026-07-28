import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';
import 'core/di/service_locator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/finance/presentation/bloc/partner/partner_bloc.dart';
import 'features/finance/presentation/bloc/partner/partner_event.dart';

void main() async {
  // 1. Garante que os bindings do Flutter estão prontos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Prepara o Banco de Dados e BLoCs
  await initDependencies();

  // 3. Inicializa o pacote de janelas
  await windowManager.ensureInitialized();

  // 4. DISPARA O APLICATIVO (Isso evita a tela branca)
  runApp(const WiaLogApp());

  // 5. Somente após o app abrir, configuramos e maximizamos a janela
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    title: 'WiaLog ERP',
  );

  // CORREÇÃO: Usando o método atualizado do pacote window_manager
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
  });
}

class WiaLogApp extends StatelessWidget {
  const WiaLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<PartnerBloc>(
          create: (context) => sl<PartnerBloc>()..add(const LoadPartners()),
        ),
      ],
      child: MaterialApp(
        title: 'WiaLog ERP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          fontFamily: 'Segoe UI',
        ),
        home: const LoginPage(),
      ),
    );
  }
}
