import 'dart:convert';
import 'dart:io';
import 'package:citoyen_app/data/models/citoyen_model.dart';
import 'package:citoyen_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:citoyen_app/config/app_constants.dart';

class CitoyenRepository {
  final ApiHelper _apiHelper = ApiHelper();

  /// Récupère le profil du citoyen connecté.
  /// Peut prendre un `token` en paramètre pour garantir l'utilisation du bon token.
  Future<Citoyen> getMyProfile({String? token}) async {
    final finalToken = token ?? await _apiHelper.getAuthToken();
    if (finalToken == null) {
      throw Exception('Token d\'authentification manquant.');
    }

    final response = await _apiHelper.getWithToken('/citoyens/me', finalToken);
    
    if (response.statusCode == 200) {
      return Citoyen.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la récupération du profil: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Met à jour les informations du profil du citoyen.
  Future<Citoyen> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiHelper.put('/citoyens/me', data); 

    if (response.statusCode == 200) {
      return Citoyen.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la mise à jour du profil: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Upload une photo de profil pour le citoyen.
  Future<String> uploadProfilePicture(int citoyenId, String imagePath) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/citoyens/$citoyenId/upload-photo');
    final request = http.MultipartRequest('POST', uri);

    final token = await _apiHelper.getAuthToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath('profilePicture', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl'];
    } else {
      throw Exception('Échec de l\'upload de la photo: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }
}