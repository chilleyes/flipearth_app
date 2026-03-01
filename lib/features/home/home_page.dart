import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded, size: 64, color: context.colors.brandBlue),
              const SizedBox(height: 16),
              Text('Home', style: context.textStyles.h2),
              const SizedBox(height: 8),
              Text(
                'V1 首页即将上线',
                style: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
