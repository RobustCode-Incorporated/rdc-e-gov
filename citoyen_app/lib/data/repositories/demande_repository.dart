// lib/data/repositories/demande_repository.dart
import 'dart:convert';
import 'package:citoyen_app/data/models/demande_model.dart';
import 'package:citoyen_app/data/models/statut_model.dart';
import 'package:citoyen_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:citoyen_app/config/app_constants.dart';

class DemandeRepository {
  final ApiHelper _apiHelper = ApiHelper();

  // MODIFICATION ICI : Ajout du paramètre 'authToken'
  Future<Demande> createDemande(Map<String, dynamic> demandeData, {String? authToken}) async {
    final response = await _apiHelper.post(
      '/demandes',
      demandeData,
      tokenOverride: authToken, // Passer le token ici
    );
    if (response.statusCode == 201) {
      return Demande.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la création de la demande: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  Future<List<Demande>> getMyDemandes() async {
    final response = await _apiHelper.get('/demandes/me');
    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return List<Demande>.from(list.map((model) => Demande.fromJson(model)));
    } else {
      throw Exception('Échec de la récupération des demandes: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  Future<Demande> getDemandeDetails(int demandeId) async {
    final response = await _apiHelper.get('/demandes/$demandeId');
    if (response.statusCode == 200) {
      return Demande.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la récupération des détails de la demande: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  Future<List<Statut>> getStatuts() async {
    final response = await _apiHelper.get('/statuts');
    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return List<Statut>.from(list.map((model) => Statut.fromJson(model)));
    } else {
      throw Exception('Échec de la récupération des statuts: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  Future<List<Demande>> getValidatedDocuments() async {
    final response = await _apiHelper.get('/demandes/me?statutId=3');
    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return List<Demande>.from(list.map((model) => Demande.fromJson(model)));
    } else {
      throw Exception('Échec de la récupération des documents validés: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  Future<void> downloadDocument(int demandeId) async {
    final downloadUrl = '${AppConstants.baseUrl}/demandes/$demandeId/download';
    throw UnimplementedError('La logique de téléchargement de document doit être implémentée.');
  }
}