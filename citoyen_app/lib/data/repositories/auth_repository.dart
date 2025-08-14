import 'dart:convert';
import 'package:citoyen_app/data/models/citoyen_model.dart';
import 'package:citoyen_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final ApiHelper _apiHelper = ApiHelper();

  Future<String?> getAuthToken() async {
    return await _apiHelper.getAuthToken();
  }

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
  /// Renvoie un Map contenant le Citoyen et le token.
  // lib/data/repositories/auth_repository.dart
// ... (previous code)

  /// Tries to register a new citizen.
  /// Saves the token and returns it upon success.
  Future<String> register(Map<String, dynamic> citoyenData) async {
    final response = await _apiHelper.post(
      '/auth/register',
      citoyenData,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        await _apiHelper.saveAuthToken(token);
        return token; // Return the token directly
      }
      throw Exception('Token not received in server response.');
    } else {
      throw Exception('Registration failed: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

// ... (rest of the file)

  Future<void> logout() async {
    await _apiHelper.deleteAuthToken();
    print('DEBUG AuthRepository: Token supprimé.');
  }

  Future<bool> isAuthenticated() async {
    final token = await _apiHelper.getAuthToken();
    return token != null && token.isNotEmpty;
  }
}