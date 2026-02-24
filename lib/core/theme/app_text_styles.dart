import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Foundational Font Family (Using Inter for modern iOS feel, falling back to system native)
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
