// lib/data/models/commune_model.dart
class Commune {
  final int id;
  final String nom;
  final String code;
  final int provinceId; // Ajouté pour la relation Province-Commune

  Commune({
    required this.id,
    required this.nom,
    required this.code,
    required this.provinceId,
  });

  factory Commune.fromJson(Map<String, dynamic> json) {
    return Commune(
      id: json['id'],
      nom: json['nom'],
      code: json['code'],
      provinceId: json['provinceId'],
    );
  }
}