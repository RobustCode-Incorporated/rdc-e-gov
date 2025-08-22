import 'package:flutter/material.dart';
import 'package:citoyen_app/data/models/citoyen_model.dart';
import 'package:citoyen_app/data/repositories/citoyen_repository.dart';

class CitoyenProvider with ChangeNotifier {
  final CitoyenRepository _citoyenRepository = CitoyenRepository();
  Citoyen? _profile; // Le profil du citoyen
  bool _isLoading = false; // Indique si une opération de profil est en cours
  String? _errorMessage; // Message d'erreur

  // Getters
  Citoyen? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupère les informations du profil du citoyen connecté.
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _citoyenRepository.getMyProfile();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement du profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour les informations du profil du citoyen.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Si ton backend gère la mise à jour par ID, tu auras besoin de _profile!.id
      _profile = await _citoyenRepository.updateProfile(data); 
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du profil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Gère l'upload d'une photo de profil.
  /// Note: Cette méthode dépend fortement de l'implémentation dans le Repository.
  Future<bool> uploadProfilePicture(int citoyenId, String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Appel au repository pour uploader l'image.
      // Le repository devrait retourner l'URL de l'image si l'upload est réussi.
      final imageUrl = await _citoyenRepository.uploadProfilePicture(citoyenId, imagePath);
      
      // Mettre à jour l'URL de la photo dans le modèle de profil local
      // Il faudrait ajouter une propriété 'profileImageUrl' à ton modèle Citoyen pour cela.
      // Exemple: _profile = _profile?.copyWith(profileImageUrl: imageUrl); 
      // Si tu n'as pas de copyWith, tu devras recréer un nouveau Citoyen avec la nouvelle URL.

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'upload de la photo: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}