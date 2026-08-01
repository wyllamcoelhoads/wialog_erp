import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);
  // 👇 1. AQUI ESTÁ A VARIÁVEL QUE A TELA DE PREFERÊNCIAS ESTÁ PEDINDO!
  bool get isDark => state == ThemeMode.dark;

  void setTheme(ThemeMode mode) => emit(mode);

  void toggleTheme() {
    emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  // 👇 3. Função NOVA para ler a String ('dark' ou 'light') que vem do Banco de Dados
  void setThemeFromPreference(String themeStr) {
    emit(themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light);
  }
}
