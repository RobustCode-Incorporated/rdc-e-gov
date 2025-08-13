import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:citoyen_app/config/app_constants.dart';

class ApiHelper {
  final _storage = const FlutterSecureStorage();

  // Récupère le token d'authentification
  Future<String?> getAuthToken() async {
    return await _storage.read(key: AppConstants.authTokenKey);
  }

  // Stocke le token d'authentification
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: AppConstants.authTokenKey, value: token);
  }

  // Supprime le token d'authentification
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: AppConstants.authTokenKey);
  }

  // Helper pour les requêtes GET
  Future<http.Response> get(String path) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final token = await getAuthToken();

    // AJOUT DE DEBUG PRINTS
    print('DEBUG API: Requête GET vers: $uri');
    print('DEBUG API: Token récupéré: $token');

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // Condition améliorée: n'ajoute le header Authorization que si le token n'est PAS null ET n'est PAS vide
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    print('DEBUG API: Headers envoyés: $headers'); // Affiche les headers réellement envoyés

    try {
      final response = await http.get(uri, headers: headers);
      print('DEBUG API: Réponse pour $path - Statut: ${response.statusCode}, Corps (partiel): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}'); // Affiche une partie du corps
      return response;
    } catch (e) {
      print('DEBUG API: Erreur lors de la requête GET vers $path: $e');
      rethrow; // Relance l'exception pour qu'elle soit gérée par le provider
    }
  }

  // Helper pour les requêtes POST
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final token = await getAuthToken();

    print('DEBUG API: Requête POST vers: $uri');
    print('DEBUG API: Token récupéré: $token');

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    print('DEBUG API: Headers envoyés: $headers');
    print('DEBUG API: Corps POST envoyé: ${jsonEncode(body)}');

    try {
      final response = await http.post(uri, headers: headers, body: jsonEncode(body));
      print('DEBUG API: Réponse pour $path - Statut: ${response.statusCode}, Corps (partiel): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      return response;
    } catch (e) {
      print('DEBUG API: Erreur lors de la requête POST vers $path: $e');
      rethrow;
    }
  }

  // Helper pour les requêtes PUT
  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final token = await getAuthToken();

    print('DEBUG API: Requête PUT vers: $uri');
    print('DEBUG API: Token récupéré: $token');

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    print('DEBUG API: Headers envoyés: $headers');
    print('DEBUG API: Corps PUT envoyé: ${jsonEncode(body)}');

    try {
      final response = await http.put(uri, headers: headers, body: jsonEncode(body));
      print('DEBUG API: Réponse pour $path - Statut: ${response.statusCode}, Corps (partiel): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      return response;
    } catch (e) {
      print('DEBUG API: Erreur lors de la requête PUT vers $path: $e');
      rethrow;
    }
  }

  // Helper pour les requêtes DELETE (si nécessaire)
  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final token = await getAuthToken();

    print('DEBUG API: Requête DELETE vers: $uri');
    print('DEBUG API: Token récupéré: $token');

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    print('DEBUG API: Headers envoyés: $headers');

    try {
      final response = await http.delete(uri, headers: headers);
      print('DEBUG API: Réponse pour $path - Statut: ${response.statusCode}, Corps (partiel): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      return response;
    } catch (e) {
      print('DEBUG API: Erreur lors de la requête DELETE vers $path: $e');
      rethrow;
    }
  }
}
