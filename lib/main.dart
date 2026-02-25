import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'core/providers/service_provider.dart';
import 'core/providers/auth_provider.dart';
import 'features/welcome/welcome_page.dart';
import 'features/layout/main_layout.dart';
import 'features/auth/login_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  ServiceProvider().init();

  runApp(const FlipEarthApp());
}

class FlipEarthApp extends StatelessWidget {
  const FlipEarthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: ServiceProvider().authService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'FlipEarth',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', ''),
          Locale('en', ''),
        ],
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColorsExtension.light.background,
          useMaterial3: true,
          extensions: const [AppColorsExtension.light],
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColorsExtension.dark.background,
          useMaterial3: true,
          extensions: const [AppColorsExtension.dark],
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/main': (context) => const MainLayout(),
        },
      ),
    );
  }
}
