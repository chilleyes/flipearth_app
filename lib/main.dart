import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'features/welcome/welcome_page.dart';
import 'features/layout/main_layout.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FlipEarthApp());
}

class FlipEarthApp extends StatelessWidget {
  const FlipEarthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlipEarth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/main': (context) => const MainLayout(),
      },
    );
  }
}
