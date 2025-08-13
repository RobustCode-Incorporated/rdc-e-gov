import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/citoyen_provider.dart';
import 'package:citoyen_app/data/providers/commune_provider.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';
import 'package:citoyen_app/presentation/screens/auth/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CitoyenProvider()),
        ChangeNotifierProvider(create: (_) => CommuneProvider()),
        ChangeNotifierProvider(create: (_) => DemandeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citoyen App',
      theme: AppTheme.lightTheme, // Utilise ton thème personnalisé
      home: const LoginScreen(), // Commence par l'écran de connexion
      debugShowCheckedModeBanner: false, // Cache le bandeau "Debug"
    );
  }
}
