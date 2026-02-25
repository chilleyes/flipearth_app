import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    bool success;

    if (_isRegisterMode) {
      success = await auth.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
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
                    Color(0xCC0F172A),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(PhosphorIconsBold.arrowLeft,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      const Icon(PhosphorIconsFill.planet,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'FlipEarth',
                        style: context.textStyles.h1.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isRegisterMode ? '创建账户' : '欢迎回来',
                    style: context.textStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegisterMode
                        ? '注册后即可享受完整的订票与行程规划服务'
                        : '登录以继续您的旅程',
                    style: context.textStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildSwitchModeRow(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Form(
          key: _formKey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    if (auth.error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          auth.error!,
                          style: context.textStyles.caption.copyWith(
                            color: const Color(0xFFFF6B6B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        label: '邮箱地址',
                        icon: PhosphorIconsRegular.envelopeSimple,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return '请输入邮箱';
                        if (!v.contains('@')) return '请输入有效邮箱';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        label: '密码',
                        icon: PhosphorIconsRegular.lock,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? PhosphorIconsRegular.eye
                                : PhosphorIconsRegular.eyeSlash,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return '请输入密码';
                        if (v.length < 6) return '密码至少 6 位';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          disabledBackgroundColor:
                              Colors.white.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5),
                              )
                            : Text(
                                _isRegisterMode ? '注册' : '登录',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white70),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildSwitchModeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isRegisterMode ? '已有账户？' : '还没有账户？',
          style: context.textStyles.bodyMedium.copyWith(color: Colors.white60),
        ),
        GestureDetector(
          onTap: () {
            setState(() => _isRegisterMode = !_isRegisterMode);
            context.read<AuthProvider>().clearError();
          },
          child: Text(
            _isRegisterMode ? ' 去登录' : ' 立即注册',
            style: context.textStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}
