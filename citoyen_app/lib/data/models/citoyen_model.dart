// lib/data/models/citoyen_model.dart
class Citoyen {
  final int id;
  final int communeId;
  final String nom;
  final String postnom;
  final String prenom;
  final DateTime dateNaissance;
  final String sexe;
  final String lieuNaissance;
  final String numeroUnique;
  // Pas de mot de passe ici pour la sécurité

  Citoyen({
    required this.id,
    required this.communeId,
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
      communeId: json['communeId'],
      nom: json['nom'],
      postnom: json['postnom'],
      prenom: json['prenom'],
      dateNaissance: DateTime.parse(json['dateNaissance']),
      sexe: json['sexe'],
      lieuNaissance: json['lieuNaissance'],
      numeroUnique: json['numeroUnique'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communeId': communeId,
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