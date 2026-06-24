import 'package:flutter/foundation.dart' show kIsWeb; // Utile pour les gardes
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

void main() {
  // Indispensable pour Flutter Web et les plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supprime le '#' des URLs (Ex: /login au lieu de /#/login)
  usePathUrlStrategy();
  
  runApp(const WebApp());
}

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Définition propre du routeur
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const _HomePage()),
        GoRoute(path: '/login', builder: (context, state) => const _LoginPage()),
      ],
      errorBuilder: (context, state) => const _NotFoundPage(),
    );

    return MaterialApp.router(
      title: 'THIX ID',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7EA4)),
        useMaterial3: true,
      ),
    );
  }
}
