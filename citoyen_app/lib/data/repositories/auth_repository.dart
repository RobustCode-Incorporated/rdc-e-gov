import 'dart:convert';
import 'package:citoyen_app/data/models/citoyen_model.dart'; // Importe le modèle Citoyen
import 'package:citoyen_app/utils/api_helper.dart'; // Importe la classe utilitaire pour les appels API
import 'package:http/http.dart' as http; // Importe le package http pour les requêtes

class AuthRepository {
  final ApiHelper _apiHelper = ApiHelper(); // Instance de l'helper API

  /// Tente de connecter un utilisateur avec son numéro unique et mot de passe.
  /// Retourne le token JWT en cas de succès, null en cas d'échec.
  Future<String?> login(String numeroUnique, String password) async {
    final response = await _apiHelper.post(
      '/auth/login', // Assure-toi que cette route correspond à ton backend Node.js
      {'username': numeroUnique, 'password': password, 'role': 'citoyen'}, // Utilise 'username' et ajoute 'role' pour le login générique
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']; // Le token devrait être renvoyé dans le corps de la réponse
      await _apiHelper.saveAuthToken(token); // Stocke le token de manière sécurisée
      return token;
    } else {
      // Lance une exception en cas d'échec de connexion pour être gérée par le Provider
      throw Exception('Échec de la connexion: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Tente d'inscrire un nouveau citoyen.
  /// Enregistre le token et retourne l'objet Citoyen créé pour permettre la connexion automatique.
  Future<Citoyen> register(Map<String, dynamic> citoyenData) async {
    final response = await _apiHelper.post(
      '/auth/register', // Assure-toi que cette route correspond à ton backend Node.js
      citoyenData,
    );

    if (response.statusCode == 201) { // 201 Created est le code attendu pour une création réussie
      final data = jsonDecode(response.body);
      final token = data['token']; // Récupère le token de la réponse
      await _apiHelper.saveAuthToken(token); // Enregistre le token de manière sécurisée

      // Retourne l'objet citoyen renvoyé par le backend
      // Assure-toi que ton backend renvoie bien l'objet citoyen sous la clé 'citoyen'
      return Citoyen.fromJson(data['citoyen']);
    } else {
      // Lance une exception en cas d'échec d'inscription
      throw Exception('Échec de l\'inscription: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Déconnecte l'utilisateur en supprimant le token stocké.
  Future<void> logout() async {
    await _apiHelper.deleteAuthToken();
  }

  /// Vérifie si un token d'authentification est actuellement stocké,
  /// indiquant si l'utilisateur est potentiellement connecté.
  Future<bool> isAuthenticated() async {
    final token = await _apiHelper.getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
