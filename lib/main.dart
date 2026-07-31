import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Usaremos o package base do flutter para Windows para definir o tamanho
import 'package:desktop_window/desktop_window.dart';
import 'package:wialog_erp/core/theme/theme_cubit.dart';
import 'package:wialog_erp/features/auth/presentation/bloc/auth_event.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/bank_account/bank_account_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/category/category_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/category/category_event.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/document/document_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/employee/employee_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/payment_method/payment_method_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/user/user_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/pages/dashboard_page.dart';
import 'package:wialog_erp/features/role/presentation/bloc/role_bloc.dart';
import 'dart:io' show Platform;

import 'core/theme/app_colors.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'core/di/service_locator.dart';
import 'features/finance/presentation/bloc/partner/partner_bloc.dart';

void main() async {
  // 1. Garante que os bindings do Flutter estão prontos para a GPU
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Prepara o Banco de Dados e BLoCs
  await initDependencies();

  // 3. (Correção do BUG): Forçamos um tamanho inicial *antes* do app rodar.
  // Isso obriga a engine a disparar um evento de resize e renderizar o primeiro frame!
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await DesktopWindow.setWindowSize(const Size(1280, 720));
    await DesktopWindow.setMinWindowSize(const Size(800, 600));
    // Não forçaremos o maximize aqui para evitar a tela branca do driver.
  }

  // 4. DISPARA O APLICATIVO
  runApp(const WiaLogApp());
}

class WiaLogApp extends StatelessWidget {
  const WiaLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
        // Adicionando o BLoC de Parceiros para todo o app ter acesso!
        BlocProvider<PartnerBloc>(create: (context) => sl<PartnerBloc>()),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(sl())..add(LoadCategories()),
        ), // ADD THIS!
        BlocProvider<DocumentBloc>(create: (context) => sl<DocumentBloc>()),
        BlocProvider<BankAccountBloc>(
          create: (context) => sl<BankAccountBloc>(),
        ),
        BlocProvider<PaymentMethodBloc>(
          create: (context) => sl<PaymentMethodBloc>(),
        ),
        BlocProvider<EmployeeBloc>(create: (context) => sl<EmployeeBloc>()),
        BlocProvider<UserBloc>(create: (context) => sl<UserBloc>()),
        BlocProvider<RoleBloc>(create: (context) => sl<RoleBloc>()),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'WiaLog ERP',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData.light(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E3A8A),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF4F6F8),
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E3A8A),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
            ),
            initialRoute: '/login',
            routes: {
              '/': (context) => const LoginPage(),
              '/dashboard': (context) => const DashboardPage(),
            },
          );
        },
      ),
    );
  }
}
