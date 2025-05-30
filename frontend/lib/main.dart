import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/eventos_screen.dart';
import 'screens/buscar_screen.dart';
import 'screens/favoritos_screen.dart';
import 'screens/perfil_screen.dart';

void main() {
  runApp(const EventosApp());
}

class EventosApp extends StatelessWidget {
  const EventosApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/registro', builder: (_, __) => const RegistroScreen()),
        GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
        GoRoute(path: '/reset', builder: (_, __) => const ResetPasswordScreen()),
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
          routes: [
            GoRoute(path: 'eventos', builder: (_, __) => const EventosScreen()),
            GoRoute(path: 'buscar', builder: (_, __) => const BuscarScreen()),
            GoRoute(path: 'favoritos', builder: (_, __) => const Favoritos_Screen()),
            GoRoute(path: 'perfil', builder: (_, __) => const PerfilScreen()),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'CulturAppFree',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // gris claro

        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF1B263B),     // azul oscuro
          onPrimary: Colors.white,
          secondary: Color(0xFF415A77),   // azul acento
          onSecondary: Colors.white,
          error: Color(0xFFB00020),
          onError: Colors.white,
          background: Color(0xFFF8F9FA),  // gris claro
          onBackground: Color(0xFF1B263B),
          surface: Colors.white,
          onSurface: Color(0xFF1B263B),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B263B),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        fontFamily: 'Montserrat',

        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Raleway'),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Raleway'),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF415A77), // azul acento
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF415A77), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: const TextStyle(color: Color(0xFF415A77)),
        ),

        dividerColor: Colors.grey.shade300,
      ),
    );
  }
}