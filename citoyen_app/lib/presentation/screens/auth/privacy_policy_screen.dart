import 'package:flutter/material.dart';
import 'package:citoyen_app/config/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Politique de confidentialité',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Nous attachons une grande importance à la protection de vos données personnelles. '
                'La présente politique de confidentialité explique quelles informations nous collectons, comment nous les utilisons et les mesures que nous prenons pour les protéger.',
              ),
              const SizedBox(height: 12.0),
              const Text(
                '1. Collecte des informations',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Nous collectons les informations suivantes lors de votre inscription et utilisation de l’application : nom, prénom, date de naissance, sexe, lieu de naissance, email, mot de passe, commune et province de résidence.',
              ),
              const SizedBox(height: 12.0),
              const Text(
                '2. Utilisation des informations',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Ces informations sont utilisées pour vous identifier, gérer votre compte, traiter vos demandes administratives et vous fournir nos services numériques.',
              ),
              const SizedBox(height: 12.0),
              const Text(
                '3. Partage des informations',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Vos données personnelles ne seront jamais vendues à des tiers. Elles peuvent être partagées avec les autorités compétentes uniquement pour le traitement de vos demandes administratives.',
              ),
              const SizedBox(height: 12.0),
              const Text(
                '4. Sécurité des données',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Nous mettons en place des mesures de sécurité appropriées pour protéger vos données contre tout accès non autorisé, modification ou suppression.',
              ),
              const SizedBox(height: 12.0),
              const Text(
                '5. Vos droits',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Vous avez le droit de consulter, modifier ou supprimer vos données personnelles. Pour toute demande, contactez notre support via l’application ou les coordonnées disponibles.',
              ),
              const SizedBox(height: 12.0),
              const Text(
                '6. Acceptation de la politique',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'En utilisant notre application et en cochant la case lors de l’inscription, vous acceptez cette politique de confidentialité.',
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('J’ai compris'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}