// lib/data/models/statut_model.dart
class Statut {
  final int id;
  final String nom;

  Statut({required this.id, required this.nom});

  factory Statut.fromJson(Map<String, dynamic> json) {
    return Statut(
      id: json['id'],
      nom: json['nom'],
    );
  }
}