import 'package:flutter/material.dart';
import 'package:citoyen_app/data/models/citoyen_model.dart'; // Importe le modèle Citoyen
import 'package:citoyen_app/data/repositories/auth_repository.dart'; // Importe le repository d'authentification
import 'package:citoyen_app/data/repositories/citoyen_repository.dart'; // Importe le repository Citoyen pour récupérer le profil

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final CitoyenRepository _citoyenRepository = CitoyenRepository();

  Citoyen? _currentCitoyen; // Le citoyen actuellement connecté
  bool _isLoading = false; // Indique si une opération est en cours (connexion, inscription)
  String? _errorMessage; // Stocke un message d'erreur si une opération échoue

  // Getters pour accéder à l'état depuis les widgets
  Citoyen? get currentCitoyen => _currentCitoyen;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Vérifie le statut d'authentification au démarrage de l'application.
  /// Tente de récupérer le profil si un token est déjà présent.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners(); // Informe les écouteurs que le chargement commence
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        // Si authentifié, tente de récupérer les informations complètes du citoyen
        _currentCitoyen = await _citoyenRepository.getMyProfile();
      } else {
        _currentCitoyen = null; // Aucun citoyen connecté
      }
    } catch (e) {
      // En cas d'erreur de vérification (ex: token expiré ou invalide), on déconnecte
      print('DEBUG AuthProvider: Erreur lors de la vérification d\'authentification: $e');
      await _authRepository.logout(); // ⭐ CORRECTION ICI : Appel à logout() de AuthRepository
      _errorMessage = 'Session expirée ou invalide. Veuillez vous reconnecter.';
      _currentCitoyen = null; // S'assurer que le profil est nul en cas d'erreur
    } finally {
      _isLoading = false;
      notifyListeners(); // Informe les écouteurs que le chargement est terminé
    }
  }

  /// Tente de connecter l'utilisateur.
  /// Met à jour l'état du citoyen et l'état de chargement/erreur.
  Future<bool> login(String numeroUnique, String password) async {
    _isLoading = true;
    _errorMessage = null; // Réinitialise l'erreur précédente
    notifyListeners();
    try {
      await _authRepository.login(numeroUnique, password);
      // Après une connexion réussie, récupère les informations complètes du citoyen
      _currentCitoyen = await _citoyenRepository.getMyProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString(); // Convertit l'exception en String
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Tente d'inscrire un nouvel utilisateur.
  /// Si l'inscription réussit, le citoyen est automatiquement connecté.
  Future<bool> register(Map<String, dynamic> citoyenData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Le repository enregistre le token et nous renvoie l'objet Citoyen créé
      final newCitoyen = await _authRepository.register(citoyenData);
      _currentCitoyen = newCitoyen; // Définit le citoyen actuel après l'inscription
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnecte l'utilisateur en supprimant le token et en réinitialisant le profil.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authRepository.logout();
    _currentCitoyen = null; // Efface le profil du citoyen
    _isLoading = false;
    notifyListeners();
  }
}
