// lib/data/repositories/demande_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:citoyen_app/data/models/demande_model.dart';
import 'package:citoyen_app/data/models/statut_model.dart';
import 'package:citoyen_app/config/app_constants.dart';

class DemandeRepository {
  // Cette méthode n'est plus nécessaire ici. Le Provider gère déjà la requête HTTP.
  // Vous pouvez la garder si vous voulez isoler la logique HTTP, mais il est plus
  // simple de la gérer directement dans le provider comme nous l'avons fait.

  // Future<void> downloadDocument(int demandeId) async {
  //   final downloadUrl = '${AppConstants.baseUrl}/demandes/$demandeId/download';
  //   throw UnimplementedError('La logique de téléchargement de document doit être implémentée.');
  // }

  Future<Demande> createDemande(Map<String, dynamic> demandeData, {required String authToken}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/demandes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(demandeData),
    );

    if (response.statusCode == 201) {
      return Demande.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la création de la demande: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  Future<List<Demande>> getMyDemandes({required String authToken}) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/demandes/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Demande.fromJson(json)).toList();
    } else {
      throw Exception('Échec de la récupération des demandes: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  Future<Demande> getDemandeDetails(int demandeId, {required String authToken}) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/demandes/$demandeId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      return Demande.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la récupération des détails de la demande: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  Future<List<Statut>> getStatuts({required String authToken}) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/statuts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Statut.fromJson(json)).toList();
    } else {
      throw Exception('Échec de la récupération des statuts: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }

  Future<List<Demande>> getValidatedDocuments({required String authToken}) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/demandes/validated'), // Nouvelle route
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Demande.fromJson(json)).toList();
    } else {
      throw Exception('Échec de la récupération des documents validés: ${jsonDecode(response.body)['message'] ?? response.body}');
    }
  }
}