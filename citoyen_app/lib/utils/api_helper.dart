// lib/utils/api_helper.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:citoyen_app/config/app_constants.dart';

class ApiHelper {
  final _storage = const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    return await _storage.read(key: AppConstants.authTokenKey);
  }

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: AppConstants.authTokenKey, value: token);
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: AppConstants.authTokenKey);
  }

  Future<http.Response> get(String path) async {
    final token = await getAuthToken();
    return getWithToken(path, token);
  }

  Future<http.Response> getWithToken(String path, String? token) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    print('DEBUG API: Requête GET vers: $uri');
    print('DEBUG API: Token récupéré: $token');

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    print('DEBUG API: Headers envoyés: $headers');

    try {
      final response = await http.get(uri, headers: headers);
      print('DEBUG API: Réponse pour $path - Statut: ${response.statusCode}, Corps (partiel): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      return response;
    } catch (e) {
      print('DEBUG API: Erreur lors de la requête GET vers $path: $e');
      rethrow;
    }
  }

  // MODIFICATION ICI : Ajout d'un paramètre optionnel 'tokenOverride'
  Future<http.Response> post(String path, Map<String, dynamic> body, {String? tokenOverride}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    // Utilise le token fourni en paramètre s'il existe, sinon récupère celui du stockage
    final token = tokenOverride ?? await getAuthToken();

    print('DEBUG API: Requête POST vers: $uri');
    print('DEBUG API: Token récupéré: $token'); // Maintenant ce log devrait afficher le token

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