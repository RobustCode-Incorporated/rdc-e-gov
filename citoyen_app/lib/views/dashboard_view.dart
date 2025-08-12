import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  final String? numeroUnique;

  const DashboardView({super.key, this.numeroUnique});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenue sur votre tableau de bord',
                // ✅ Correction ici : headline6 remplacé par headlineSmall
                style: Theme.of(context).textTheme.headlineSmall, 
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (numeroUnique != null) ...[
                Text(
                  'Votre numéro unique :',
                  style: Theme.of(context).textTheme.titleMedium, // subtitle1 est aussi déprécié, remplacé par titleMedium
                ),
                const SizedBox(height: 8),
                Text(
                  numeroUnique!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ] else ...[
                const Text(
                  'Aucun numéro unique disponible',
                  style: TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // TODO: Naviguer vers les demandes du citoyen
                },
                child: const Text('Voir mes demandes'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // TODO: Ajouter d’autres actions comme modifier profil, notifications etc.
                },
                child: const Text('Modifier mon profil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
