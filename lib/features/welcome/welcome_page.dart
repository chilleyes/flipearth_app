import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    final loggedIn = await auth.checkAuthStatus();
    if (!mounted) return;
    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(PhosphorIconsFill.planet,
                  color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text('FlipEarth',
                  style: context.textStyles.h1.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 28)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.network(
                'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&q=80&w=1000',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0x660F172A),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsFill.planet,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('FlipEarth',
                          style: context.textStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 32,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('探索欧洲，\n触手可及。',
                    style: context.textStyles.h1.copyWith(
                        color: Colors.white,
                        fontSize: 42,
                        height: 1.1,
                        letterSpacing: -1.0)),
                const SizedBox(height: 16),
                Text('AI 智能规划，官方直达购票，\n开启您的纯粹旅行体验。',
                    style: context.textStyles.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.5,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(PhosphorIconsBold.envelopeSimple,
                            color: Color(0xFF0F172A), size: 22),
                        const SizedBox(width: 8),
                        Text('邮箱登录 / 注册',
                            style: context.textStyles.bodyMedium.copyWith(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/main'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF475569)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(PhosphorIconsRegular.eyeSlash,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text('先逛逛',
                                style: context.textStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: context.textStyles.caption.copyWith(
                          color: context.colors.textMuted,
                          fontWeight: FontWeight.w500),
                      children: [
                        const TextSpan(text: '继续即代表您同意 '),
                        TextSpan(
                            text: '服务条款',
                            style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Colors.white.withOpacity(0.5))),
                        const TextSpan(text: ' 及 '),
                        TextSpan(
                            text: '隐私政策',
                            style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Colors.white.withOpacity(0.5))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
