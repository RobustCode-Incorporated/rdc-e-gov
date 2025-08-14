// lib/data/providers/demande_provider.dart
import 'package:flutter/material.dart';
import 'package:citoyen_app/data/models/demande_model.dart';
import 'package:citoyen_app/data/models/statut_model.dart';
import 'package:citoyen_app/data/repositories/demande_repository.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart'; // Importe AuthProvider

class DemandeProvider with ChangeNotifier {
  final DemandeRepository _demandeRepository = DemandeRepository();
  List<Demande> _demandes = [];
  List<Demande> _validatedDocuments = [];
  List<Statut> _statuts = [];
  bool _isLoading = false;
  String? _errorMessage;

  final AuthProvider _authProvider; // Référence à AuthProvider

  DemandeProvider(this._authProvider); // Constructeur pour injection

  List<Demande> get demandes => _demandes;
  List<Demande> get validatedDocuments => _validatedDocuments;
  List<Statut> get statuts => _statuts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupère toutes les demandes effectuées par le citoyen connecté.
  @override
  Future<void> fetchMyDemandes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _demandes = await _demandeRepository.getMyDemandes();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des demandes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère la liste de tous les statuts possibles (ex: soumise, en traitement, validée).
  @override
  Future<void> fetchStatuts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _statuts = await _demandeRepository.getStatuts();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des statuts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée une nouvelle demande de document.
  /// Récupère le token directement de l'AuthProvider et le passe au repository.
  @override
  Future<bool> createDemande(Map<String, dynamic> demandeData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Récupère le token directement de l'état de l'AuthProvider (qui devrait être à jour)
      final String? authToken = _authProvider.authToken; // Appel direct sans await

      if (authToken == null) {
        _errorMessage = 'Token d\'authentification manquant. Veuillez vous reconnecter.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _demandeRepository.createDemande(demandeData, authToken: authToken); // Passe le token
      await fetchMyDemandes(); // Actualise la liste des demandes après la création
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la création de la demande: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Récupère les documents qui ont été validés pour le citoyen.
  @override
  Future<void> fetchValidatedDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _validatedDocuments = await _demandeRepository.getValidatedDocuments();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des documents validés: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lance le téléchargement d'un document validé.
  @override
  Future<void> downloadDocument(int demandeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _demandeRepository.downloadDocument(demandeId);
    } catch (e) {
      _errorMessage = 'Erreur lors du téléchargement du document: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
