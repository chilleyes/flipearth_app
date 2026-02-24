import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;
  final Color surfaceWhite;
  final Color brandBlue;
  final Color textMain;
  final Color textSecondary;
  final Color textMuted;
  final Color borderLight;
  final Color successGreen;
  final Color purpleGlow;

  const AppColorsExtension({
    required this.background,
    required this.surfaceWhite,
    required this.brandBlue,
    required this.textMain,
    required this.textSecondary,
    required this.textMuted,
    required this.borderLight,
    required this.successGreen,
    required this.purpleGlow,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? background,
    Color? surfaceWhite,
    Color? brandBlue,
    Color? textMain,
    Color? textSecondary,
    Color? textMuted,
    Color? borderLight,
    Color? successGreen,
    Color? purpleGlow,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surfaceWhite: surfaceWhite ?? this.surfaceWhite,
      brandBlue: brandBlue ?? this.brandBlue,
      textMain: textMain ?? this.textMain,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      borderLight: borderLight ?? this.borderLight,
      successGreen: successGreen ?? this.successGreen,
      purpleGlow: purpleGlow ?? this.purpleGlow,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surfaceWhite: Color.lerp(surfaceWhite, other.surfaceWhite, t)!,
      brandBlue: Color.lerp(brandBlue, other.brandBlue, t)!,
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      successGreen: Color.lerp(successGreen, other.successGreen, t)!,
      purpleGlow: Color.lerp(purpleGlow, other.purpleGlow, t)!,
    );
  }

  static const light = AppColorsExtension(
    background: Color(0xFFF8FAFC),
    surfaceWhite: Color(0xFFFFFFFF),
    brandBlue: Color(0xFF0EA5E9),
    textMain: Color(0xFF0F172A), // slate-900
    textSecondary: Color(0xFF64748B), // slate-500
    textMuted: Color(0xFF94A3B8), // slate-400
    borderLight: Color(0xFFF1F5F9), // slate-100
    successGreen: Color(0xFF10B981),
    purpleGlow: Color(0xFFA855F7),
  );

  static const dark = AppColorsExtension(
    background: Color(0xFF020617), // slate-950
    surfaceWhite: Color(0xFF0F172A), // slate-900
    brandBlue: Color(0xFF0EA5E9), // keep neon blue
    textMain: Color(0xFFF8FAFC), // slate-50
    textSecondary: Color(0xFF94A3B8), // slate-400
    textMuted: Color(0xFF475569), // slate-600
    borderLight: Color(0xFF1E293B), // slate-800
    successGreen: Color(0xFF10B981),
    purpleGlow: Color(0xFFA855F7),
  );

  LinearGradient get heroGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      const Color(0x80000000), // black/50
      const Color(0x0C000000), // black/5
      background,
    ],
  );

  LinearGradient get fabGlowGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      brandBlue,
      purpleGlow,
      brandBlue,
    ],
  );
}

extension AppColorsContextExtension on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}

class AppColors {
  // We keep constants just as fallbacks or for places without context if strictly needed,
  // but ideally they are replaced with context.colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color brandBlue = Color(0xFF0EA5E9);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color successGreen = Color(0xFF10B981);
  static const Color purpleGlow = Color(0xFFA855F7);
}
