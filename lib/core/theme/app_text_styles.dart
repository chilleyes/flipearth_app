import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStylesExtension extends ThemeExtension<AppTextStylesExtension> {
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle caption;

  const AppTextStylesExtension({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.caption,
  });

  @override
  ThemeExtension<AppTextStylesExtension> copyWith({
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? caption,
  }) {
    return AppTextStylesExtension(
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      caption: caption ?? this.caption,
    );
  }

  @override
  ThemeExtension<AppTextStylesExtension> lerp(ThemeExtension<AppTextStylesExtension>? other, double t) {
    if (other is! AppTextStylesExtension) return this;
    return AppTextStylesExtension(
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }

  static AppTextStylesExtension fromColors(AppColorsExtension colors) {
    final baseStyle = GoogleFonts.inter();
    return AppTextStylesExtension(
      h1: baseStyle.copyWith(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        color: colors.textMain,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      h2: baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: colors.textMain,
      ),
      h3: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: colors.textMain,
        letterSpacing: -0.2,
      ),
      bodyLarge: baseStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: colors.textMain,
      ),
      bodyMedium: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.textMain,
      ),
      bodySmall: baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
      ),
      caption: baseStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: colors.textMuted,
      ),
    );
  }
}

extension AppTextStylesContextExtension on BuildContext {
  AppTextStylesExtension get textStyles =>
      Theme.of(this).extension<AppTextStylesExtension>() ??
      AppTextStylesExtension.fromColors(Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light);
}

class AppTextStyles {
  static final TextStyle baseStyle = GoogleFonts.inter();

  static final TextStyle h1 = baseStyle.copyWith(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static final TextStyle h2 = baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
  );

  static final TextStyle h3 = baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
    letterSpacing: -0.2,
  );

  static final TextStyle bodyLarge = baseStyle.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );

  static final TextStyle bodyMedium = baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMain,
  );

  static final TextStyle bodySmall = baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle caption = baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
  );
}
