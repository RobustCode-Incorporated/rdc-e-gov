// lib/data/models/citoyen_model.dart
import 'package:citoyen_app/data/models/commune_model.dart';

class Citoyen {
  final int id;
  // Le modèle Citoyen contient maintenant un objet Commune complet
  final Commune commune; 
  final String nom;
  final String postnom;
  final String prenom;
  final DateTime dateNaissance;
  final String sexe;
  final String lieuNaissance;
  final String numeroUnique;

  Citoyen({
    required this.id,
    required this.commune, 
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.dateNaissance,
    required this.sexe,
    required this.lieuNaissance,
    required this.numeroUnique,
  });

  factory Citoyen.fromJson(Map<String, dynamic> json) {
    return Citoyen(
      id: json['id'],
      // Désérialisez l'objet imbriqué 'commune' en utilisant le factory du modèle Commune.
      // Le backend renvoie 'commune' comme un objet JSON, nous le mappons directement.
      commune: Commune.fromJson(json['commune']), 
      nom: json['nom'],
      postnom: json['postnom'],
      prenom: json['prenom'],
      // Assurez-vous de gérer les valeurs nulles pour dateNaissance
      dateNaissance: json['dateNaissance'] != null 
          ? DateTime.parse(json['dateNaissance']) 
          : DateTime.now(), // Fallback en cas de valeur nulle
      sexe: json['sexe'],
      lieuNaissance: json['lieuNaissance'],
      numeroUnique: json['numeroUnique'],
    );
  }

  // Le toJson est utile pour envoyer des données au serveur, par exemple lors d'une mise à jour.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Envoyez l'ID de la commune, comme le serveur s'y attend pour les relations.
      'communeId': commune.id, 
      'nom': nom,
      'postnom': postnom,
      'prenom': prenom,
      'dateNaissance': dateNaissance.toIso8601String(),
      'sexe': sexe,
      'lieuNaissance': lieuNaissance,
      'numeroUnique': numeroUnique,
    };
  }
}