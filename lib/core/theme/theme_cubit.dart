import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  // Aplica o tema que vem do banco de dados ao fazer login
  void setTheme(String themeStr) {
    emit(themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light);
  }

  // Alterna o tema no clique do Switch
  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  bool get isDark => state == ThemeMode.dark;
}
