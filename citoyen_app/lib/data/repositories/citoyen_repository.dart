import 'dart:convert';
import 'dart:io'; // Pour le type File lors de l'upload d'image
import 'package:citoyen_app/data/models/citoyen_model.dart';
import 'package:citoyen_app/utils/api_helper.dart';
import 'package:http/http.dart' as http; // Nécessaire pour les requêtes POST/PUT
import 'package:citoyen_app/config/app_constants.dart'; // NOUVEL IMPORT NÉCESSAIRE

class CitoyenRepository {
  final ApiHelper _apiHelper = ApiHelper();

  /// Récupère les informations du profil du citoyen actuellement connecté.
  /// Le backend devrait identifier le citoyen via le token JWT dans les headers.
  Future<Citoyen> getMyProfile() async {
    // La route '/citoyens/me' est une convention courante pour récupérer le profil de l'utilisateur authentifié
    final response = await _apiHelper.get('/citoyens/me'); 
    
    if (response.statusCode == 200) {
      return Citoyen.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la récupération du profil: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Met à jour les informations du profil du citoyen.
  /// Le backend devrait identifier le citoyen via le token JWT.
  Future<Citoyen> updateProfile(Map<String, dynamic> data) async {
    // Si ton backend gère la mise à jour par token, la route peut être /citoyens/me
    // Sinon, elle pourrait être /citoyens/:id, où l'id serait récupéré du profil Citoyen local.
    final response = await _apiHelper.put('/citoyens/me', data); 

    if (response.statusCode == 200) {
      return Citoyen.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la mise à jour du profil: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Upload une photo de profil pour le citoyen.
  /// Cette implémentation est une version simplifiée.
  /// **IMPORTANT :** Pour un upload de fichier robuste, tu devrais utiliser un package comme `dio`
  /// ou `http` avec `MultipartFile` pour envoyer des données `multipart/form-data`
  /// à ton backend qui doit être configuré pour recevoir des fichiers.
  /// Le backend devrait retourner l'URL publique de l'image.
  Future<String> uploadProfilePicture(int citoyenId, String imagePath) async {
    // CORRECTION ICI : Utilise AppConstants.baseUrl
    final uri = Uri.parse('${AppConstants.baseUrl}/citoyens/$citoyenId/upload-photo'); // Exemple de route
    final request = http.MultipartRequest('POST', uri); // Ou 'PUT' si c'est une mise à jour

    // Ajoute le token d'authentification aux headers
    final token = await _apiHelper.getAuthToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Ajoute le fichier à la requête
    request.files.add(await http.MultipartFile.fromPath('profilePicture', imagePath)); // 'profilePicture' doit correspondre au nom du champ attendu par ton backend

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl']; // Assure-toi que ton backend retourne l'URL de l'image
    } else {
      throw Exception('Échec de l\'upload de la photo: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }
}
