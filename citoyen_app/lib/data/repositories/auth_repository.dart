import 'dart:convert';
import 'package:citoyen_app/data/models/citoyen_model.dart';
import 'package:citoyen_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final ApiHelper _apiHelper = ApiHelper();

  // NOUVEAU : Méthode pour obtenir le token d'authentification
  /// Délègue la récupération du token à ApiHelper.
  Future<String?> getAuthToken() async {
    return await _apiHelper.getAuthToken();
  }

  /// Tente de connecter un utilisateur et retourne le token JWT en cas de succès.
  Future<String?> login(String numeroUnique, String password) async {
    final response = await _apiHelper.post(
      '/auth/login',
      {'username': numeroUnique, 'password': password, 'role': 'citoyen'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        await _apiHelper.saveAuthToken(token);
        print('DEBUG AuthRepository: Nouveau token sauvegardé avec succès.');
        return token;
      }
      throw Exception('Token non reçu dans la réponse du serveur.');
    } else {
      throw Exception('Échec de la connexion: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Tente d'inscrire un nouveau citoyen.
  /// Enregistre le token et retourne l'objet Citoyen créé pour la connexion automatique.
  Future<Citoyen> register(Map<String, dynamic> citoyenData) async {
    final response = await _apiHelper.post(
      '/auth/register',
      citoyenData,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        await _apiHelper.saveAuthToken(token);
      }
      return Citoyen.fromJson(data['citoyen']);
    } else {
      throw Exception('Échec de l\'inscription: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Déconnecte l'utilisateur en supprimant le token stocké.
  Future<void> logout() async {
    await _apiHelper.deleteAuthToken();
    print('DEBUG AuthRepository: Token supprimé.');
  }

  /// Vérifie si un token d'authentification est actuellement stocké.
  Future<bool> isAuthenticated() async {
    final token = await _apiHelper.getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
