import 'package:flutter/material.dart';

class AppColors {
  // Primary background color mapping to var(--bg-color) / slate-50
  static const Color background = Color(0xFFF8FAFC);
  
  // Brand Blue mapping to tailwind brand-blue / sky-500
  static const Color brandBlue = Color(0xFF0EA5E9);
  
  // Generic state colors
  static const Color textMain = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textMuted = Color(0xFF94A3B8); // slate-400
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFF1F5F9); // slate-100
  
  // Specific semantic colors from HTML
  static const Color successGreen = Color(0xFF10B981); // emerald-500
  static const Color purpleGlow = Color(0xFFA855F7); // purple-500
  
  // Shared Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x80000000), // black/50
      Color(0x0C000000), // black/5
      background,
    ],
  );
  
  static const LinearGradient fabGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      brandBlue,
      purpleGlow,
      brandBlue,
    ],
  );
}
