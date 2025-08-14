import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/citoyen_provider.dart';
import 'package:citoyen_app/data/providers/commune_provider.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';
import 'package:citoyen_app/presentation/screens/auth/login_screen.dart';
import 'package:citoyen_app/presentation/screens/dashboard/dashboard_screen.dart'; // N'oubliez pas d'importer le DashboardScreen

void main() {
  runApp(
    MultiProvider(
      providers: [
        // AuthProvider n'a pas de dépendances directes, donc un simple ChangeNotifierProvider suffit.
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // CitoyenProvider et CommuneProvider n'ont pas été modifiés pour dépendre d'autres providers
        ChangeNotifierProvider(create: (_) => CitoyenProvider()),
        ChangeNotifierProvider(create: (_) => CommuneProvider()),
        
        // DemandeProvider dépend de AuthProvider.
        // On utilise ChangeNotifierProxyProvider pour fournir AuthProvider à DemandeProvider.
        ChangeNotifierProxyProvider<AuthProvider, DemandeProvider>(
          // Le `create` est appelé la première fois pour créer DemandeProvider.
          // On accède ici à AuthProvider via `Provider.of` et on le passe au constructeur.
          create: (context) => DemandeProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          // Le `update` est appelé si AuthProvider change (rare).
          // Il assure que DemandeProvider a toujours la dernière instance de AuthProvider.
          update: (context, auth, previousDemandeProvider) {
            return DemandeProvider(auth); // Recrée ou met à jour avec la nouvelle instance d'AuthProvider
          },
        ),
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
      theme: AppTheme.lightTheme,
      // Utilise un Consumer pour décider de l'écran initial basé sur l'état d'authentification.
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Affiche un indicateur de chargement pendant la vérification initiale de l'authentification.
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            );
          } 
          // Si un citoyen est connecté, affiche le Dashboard.
          else if (authProvider.currentCitoyen != null) {
            return const DashboardScreen();
          } 
          // Sinon, affiche l'écran de connexion.
          else {
            return const LoginScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}