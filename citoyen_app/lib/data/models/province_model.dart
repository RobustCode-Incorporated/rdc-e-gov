// lib/data/models/province_model.dart
// Cette table n'était pas fournie, mais est nécessaire pour la logique Province-Commune
class Province {
  final int id;
  final String nom;

  Province({required this.id, required this.nom});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      nom: json['nom'],
    );
  }
}