import 'dart:convert';
import 'package:citoyen_app/data/models/demande_model.dart';
import 'package:citoyen_app/data/models/statut_model.dart';
import 'package:citoyen_app/utils/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:citoyen_app/config/app_constants.dart'; // NOUVEL IMPORT NÉCESSAIRE

class DemandeRepository {
  final ApiHelper _apiHelper = ApiHelper();

  /// Crée une nouvelle demande de document.
  Future<Demande> createDemande(Map<String, dynamic> demandeData) async {
    // Assure-toi que donneesJson est bien un objet JSON dans demandeData
    // et que ton backend gère la conversion JSON en JSONB/text.
    final response = await _apiHelper.post(
      '/demandes', // Route définie dans server.js
      demandeData,
    );
    if (response.statusCode == 201) {
      return Demande.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la création de la demande: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Récupère toutes les demandes effectuées par le citoyen connecté.
  Future<List<Demande>> getMyDemandes() async {
    // Si ton backend filtre par token, /demandes/me est idéal.
    // Sinon, tu devras peut-être passer l'ID du citoyen comme paramètre: '/demandes?citoyenId=X'
    final response = await _apiHelper.get('/demandes/me');
    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return List<Demande>.from(list.map((model) => Demande.fromJson(model)));
    } else {
      throw Exception('Échec de la récupération des demandes: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Récupère les détails d'une demande spécifique par son ID.
  Future<Demande> getDemandeDetails(int demandeId) async {
    final response = await _apiHelper.get('/demandes/$demandeId');
    if (response.statusCode == 200) {
      return Demande.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la récupération des détails de la demande: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Récupère la liste de tous les statuts de demande disponibles.
  Future<List<Statut>> getStatuts() async {
    final response = await _apiHelper.get('/statuts'); // Route définie dans server.js
    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return List<Statut>.from(list.map((model) => Statut.fromJson(model)));
    } else {
      throw Exception('Échec de la récupération des statuts: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Récupère la liste des documents validés pour le citoyen connecté.
  /// Ceci filtre les demandes par statutId=3 (validée) en supposant cette convention.
  Future<List<Demande>> getValidatedDocuments() async {
    final response = await _apiHelper.get('/demandes/me?statutId=3');
    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return List<Demande>.from(list.map((model) => Demande.fromJson(model)));
    } else {
      throw Exception('Échec de la récupération des documents validés: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  /// Cette fonction est un placeholder.
  /// Pour un téléchargement réel de document, tu devras :
  /// 1. Obtenir une URL de téléchargement sécurisée de ton backend.
  /// 2. Utiliser un package comme `url_launcher` pour ouvrir l'URL dans un navigateur
  ///    ou `path_provider` et `http` pour télécharger et sauvegarder le fichier localement.
  Future<void> downloadDocument(int demandeId) async {
    // CORRECTION ICI : Utilise AppConstants.baseUrl
    final downloadUrl = '${AppConstants.baseUrl}/demandes/$demandeId/download';
    // Ici, tu lancerais le téléchargement, par exemple en ouvrant l'URL dans le navigateur :
    // if (await canLaunchUrl(Uri.parse(downloadUrl))) {
    //   await launchUrl(Uri.parse(downloadUrl));
    // } else {
    //   throw Exception('Impossible de lancer le téléchargement.');
    // }
    throw UnimplementedError('La logique de téléchargement de document doit être implémentée.');
  }
}
