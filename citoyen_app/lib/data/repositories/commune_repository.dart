import 'dart:convert';
import 'package:citoyen_app/data/models/commune_model.dart';
import 'package:citoyen_app/data/models/province_model.dart';
import 'package:citoyen_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:citoyen_app/config/app_constants.dart'; // Import nécessaire pour AppConstants.baseUrl

class CommuneRepository {
  final ApiHelper _apiHelper = ApiHelper();

  /// Récupère la liste de toutes les provinces disponibles.
  Future<List<Province>> getProvinces() async {
    print('DEBUG: Tentative de récupération des provinces depuis: ${AppConstants.baseUrl}/provinces'); // Debug print
    final response = await _apiHelper.get('/provinces'); // Route définie dans server.js
    print('DEBUG: Réponse API Provinces - Statut: ${response.statusCode}, Corps: ${response.body}'); // Debug print

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return List<Province>.from(list.map((model) => Province.fromJson(model)));
    } else {
      // Pour un meilleur débogage, incluez le corps de la réponse en cas d'erreur
      throw Exception('Échec de la récupération des provinces: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Récupère la liste des communes associées à une province spécifique.
  Future<List<Commune>> getCommunesByProvinceId(int provinceId) async {
    // Utilise un paramètre de requête pour filtrer les communes par provinceId
    print('DEBUG: Tentative de récupération des communes pour provinceId: $provinceId depuis: ${AppConstants.baseUrl}/communes?provinceId=$provinceId'); // Debug print
    final response = await _apiHelper.get('/communes?provinceId=$provinceId'); 
    print('DEBUG: Réponse API Communes - Statut: ${response.statusCode}, Corps: ${response.body}'); // Debug print
    
    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return List<Commune>.from(list.map((model) => Commune.fromJson(model)));
    } else {
      // Pour un meilleur débogage, incluez le corps de la réponse en cas d'erreur
      throw Exception('Échec de la récupération des communes: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }
}
