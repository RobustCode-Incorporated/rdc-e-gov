// lib/config/app_constants.dart
class AppConstants {
  // L'URL de base de votre backend.
  // IMPORTANT : Adaptez cette URL en fonction de votre environnement.
  // Si vous testez sur un émulateur Android vers un backend local sur votre machine: 'http://10.0.2.2:4000/api'
  // Si vous testez sur un simulateur iOS (iPhone) vers un backend local sur votre machine: 'http://localhost:4000/api'
  // Si votre backend est déployé sur un serveur distant: 'https://votredomaine.com:4000/api' (ou sans port si c'est le port 80/443)
  static const String baseUrl = 'http://172.20.10.7:4000/api'; // Exemple pour émulateur Android

  // Clé pour le stockage sécurisé du token d'authentification
  static const String authTokenKey = 'authToken';
}
