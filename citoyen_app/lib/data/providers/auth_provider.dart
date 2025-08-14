// lib/data/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:citoyen_app/data/models/citoyen_model.dart';
import 'package:citoyen_app/data/repositories/auth_repository.dart';
import 'package:citoyen_app/data/repositories/citoyen_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final CitoyenRepository _citoyenRepository = CitoyenRepository();

  Citoyen? _currentCitoyen;
  String? _token; // Nouveau : stocke le token directement dans le provider
  bool _isLoading = false;
  String? _errorMessage;

  Citoyen? get currentCitoyen => _currentCitoyen;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get authToken => _token; // Nouveau getter pour le token en mémoire

  /// Vérifie le statut d'authentification au démarrage de l'application.
  /// Tente de récupérer le profil si un token est déjà présent.
  @override
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final storedToken = await _authRepository.getAuthToken(); // Obtient le token du stockage
      if (storedToken != null && storedToken.isNotEmpty) {
        _token = storedToken; // Définit le token interne
        // Utilise le token interne pour récupérer le profil
        _currentCitoyen = await _citoyenRepository.getMyProfile(token: _token);
      } else {
        _token = null; // Aucun token valide, donc pas de citoyen connecté
        _currentCitoyen = null;
      }
    } catch (e) {
      print('DEBUG AuthProvider: Erreur lors de la vérification d\'authentification: $e');
      await _authRepository.logout(); // Déconnexion en cas d'erreur grave
      _token = null; // Vide le token interne
      _errorMessage = 'Session expirée ou invalide. Veuillez vous reconnecter.';
      _currentCitoyen = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tente de connecter l'utilisateur.
  /// Met à jour l'état du citoyen et l'état de chargement/erreur.
  @override
  Future<bool> login(String numeroUnique, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newToken = await _authRepository.login(numeroUnique, password);
      
      if (newToken != null) {
        _token = newToken; // Définit le token interne après une connexion réussie
        _currentCitoyen = await _citoyenRepository.getMyProfile(token: _token);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Échec de la connexion: Token non reçu.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Tente d'inscrire un nouvel utilisateur.
  /// Si l'inscription réussit, le citoyen est automatiquement connecté.
  @override
  Future<bool> register(Map<String, dynamic> citoyenData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newCitoyen = await _authRepository.register(citoyenData);
      _token = await _authRepository.getAuthToken(); // Récupère le token après l'inscription (il est sauvegardé par le repo)
      _currentCitoyen = newCitoyen;
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
  @override
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authRepository.logout();
    _token = null; // Efface le token interne à la déconnexion
    _currentCitoyen = null;
    _isLoading = false;
    notifyListeners();
  }
}
