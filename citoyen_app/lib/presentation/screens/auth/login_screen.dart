import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
// Suppression des imports directs des écrans de navigation
// import 'package:citoyen_app/presentation/screens/auth/register_screen.dart';
// import 'package:citoyen_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:citoyen_app/utils/app_router.dart'; // Import de AppRouter

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _numeroUniqueController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _numeroUniqueController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.primaryRed : AppColors.primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion Citoyen'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ou illustration
                  Image.asset(
                    'assets/images/app_logo.png', // Assure-toi d'avoir un logo dans assets/images/
                    height: 120,
                  ),
                  const SizedBox(height: 32.0),
                  Text(
                    'Bienvenue',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Connectez-vous à votre compte',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.brownText,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  TextField(
                    controller: _numeroUniqueController,
                    decoration: InputDecoration(
                      labelText: 'Numéro Unique Citoyen (NUC)',
                      hintText: 'Ex: 1234567890',
                      prefixIcon: const Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      hintText: '********',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24.0),
                  authProvider.isLoading
                      ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                      : ElevatedButton(
                          onPressed: () async {
                            final success = await authProvider.login(
                              _numeroUniqueController.text,
                              _passwordController.text,
                            );
                            if (success) {
                              _showSnackBar('Connexion réussie !');
                              // Utilisation de AppRouter pour la navigation
                              AppRouter.navigateToDashboard(context);
                            } else {
                              _showSnackBar(authProvider.errorMessage ?? 'Erreur de connexion.', isError: true);
                            }
                          },
                          child: const Text('Se connecter'),
                        ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      // Utilisation d'un SnackBar pour les fonctionnalités non implémentées
                      _showSnackBar('Fonctionnalité "Mot de passe oublié" à implémenter.');
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore inscrit ?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          // Utilisation de AppRouter pour la navigation
                          AppRouter.navigateToRegister(context);
                        },
                        child: Text(
                          'S\'inscrire',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
