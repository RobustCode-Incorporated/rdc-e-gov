// lib/data/models/demande_model.dart
import 'dart:convert';

class Demande {
  final int id;
  final int citoyenId;
  final int communeId;
  final int statutId;
  final DateTime createdAt;
  final String typeDemande;
  final Map<String, dynamic> donneesJson; // Pour les données spécifiques
  final String? commentaires; // Peut être null
  final int? agentId; // Peut être null

  Demande({
    required this.id,
    required this.citoyenId,
    required this.communeId,
    required this.statutId,
    required this.createdAt,
    required this.typeDemande,
    required this.donneesJson,
    this.commentaires,
    this.agentId,
  });

  factory Demande.fromJson(Map<String, dynamic> json) {
    return Demande(
      id: json['id'],
      citoyenId: json['citoyenId'],
      communeId: json['communeId'],
      statutId: json['statutId'],
      createdAt: DateTime.parse(json['createdAt']),
      typeDemande: json['typeDemande'],
      // Assurez-vous que donneesJson est bien un objet JSON stringifié dans votre backend
      donneesJson: jsonDecode(json['donneesJson']), 
      commentaires: json['commentaires'],
      agentId: json['agentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'citoyenId': citoyenId,
      'communeId': communeId,
      'statutId': statutId,
      'createdAt': createdAt.toIso8601String(),
      'typeDemande': typeDemande,
      'donneesJson': jsonEncode(donneesJson), // Encoder en JSON string
      'commentaires': commentaires,
      'agentId': agentId,
    };
  }
}