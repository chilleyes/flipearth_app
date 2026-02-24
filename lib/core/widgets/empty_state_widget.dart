import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = PhosphorIconsRegular.planet,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.colors.brandBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 48,
                color: context.colors.brandBlue.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Text Content
          Text(
            title,
            style: context.textStyles.h2.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Optional action button
          if (buttonText != null && onButtonTap != null)
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.textMain,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: Text(
                  buttonText!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
