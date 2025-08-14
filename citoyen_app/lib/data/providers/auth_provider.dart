// lib/data/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:citoyen_app/data/models/citoyen_model.dart';
import 'package:citoyen_app/data/repositories/auth_repository.dart';
import 'package:citoyen_app/data/repositories/citoyen_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final CitoyenRepository _citoyenRepository = CitoyenRepository();

  Citoyen? _currentCitoyen;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  Citoyen? get currentCitoyen => _currentCitoyen;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get authToken => _token;

  /// Checks the authentication status on app startup.
  /// Attempts to retrieve the profile if a token is already present.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final storedToken = await _authRepository.getAuthToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        _token = storedToken;
        _currentCitoyen = await _citoyenRepository.getMyProfile(token: _token);
      } else {
        _token = null;
        _currentCitoyen = null;
      }
    } catch (e) {
      print('DEBUG AuthProvider: Erreur lors de la vérification d\'authentification: $e');
      await _authRepository.logout();
      _token = null;
      _errorMessage = 'Session expirée ou invalide. Veuillez vous reconnecter.';
      _currentCitoyen = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tries to log in the user.
  /// Updates the citizen's state and loading/error status.
  Future<bool> login(String numeroUnique, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newToken = await _authRepository.login(numeroUnique, password);
      
      if (newToken != null) {
        _token = newToken;
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

  /// Tries to register a new user.
  /// If registration is successful, the citizen is automatically logged in.
  Future<bool> register(Map<String, dynamic> citoyenData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newToken = await _authRepository.register(citoyenData);
      
      if (newToken != null) {
        _token = newToken; // Sets the internal token
        // Uses the new token to fetch the citizen's profile
        _currentCitoyen = await _citoyenRepository.getMyProfile(token: _token);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _errorMessage = 'Échec de l\'inscription: Token non reçu.';
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

  /// Logs out the user by deleting the stored token and resetting the profile.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authRepository.logout();
    _token = null;
    _currentCitoyen = null;
    _isLoading = false;
    notifyListeners();
  }
}