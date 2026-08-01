import 'package:flutter/material.dart';

@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  final Color sidebar;
  final Color background;
  final Color surface;
  final Color textTitle;
  final Color textBody;
  final Color textMuted;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  const AppColorsExt({
    required this.sidebar,
    required this.background,
    required this.surface,
    required this.textTitle,
    required this.textBody,
    required this.textMuted,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });

  static const light = AppColorsExt(
    sidebar: Color(0xFF1E3A8A),
    background: Color(0xFFF4F6F8),
    surface: Colors.white,
    textTitle: Color(0xFF2C3E50),
    textBody: Color(0xFF34495E),
    textMuted: Colors.grey,
    success: Color(0xFF2E7D32),
    error: Color(0xFFD32F2F),
    warning: Color(0xFFF57C00),
    info: Color(0xFF1976D2),
  );

  static const dark = AppColorsExt(
    sidebar: Color(0xFF101A3D),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    textTitle: Color(0xFFECEFF1),
    textBody: Color(0xFFCFD8DC),
    textMuted: Color(0xFF9E9E9E),
    success: Color(0xFF66BB6A),
    error: Color(0xFFEF5350),
    warning: Color(0xFFFFA726),
    info: Color(0xFF42A5F5),
  );

  @override
  AppColorsExt copyWith({
    Color? sidebar,
    Color? background,
    Color? surface,
    Color? textTitle,
    Color? textBody,
    Color? textMuted,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
  }) {
    return AppColorsExt(
      sidebar: sidebar ?? this.sidebar,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textTitle: textTitle ?? this.textTitle,
      textBody: textBody ?? this.textBody,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) return this;
    return AppColorsExt(
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textTitle: Color.lerp(textTitle, other.textTitle, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

// Atalho: context.appColors.sidebar
extension AppColorsX on BuildContext {
  AppColorsExt get appColors => Theme.of(this).extension<AppColorsExt>()!;
}
