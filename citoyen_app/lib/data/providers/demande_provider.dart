import 'package:flutter/material.dart';
import 'package:citoyen_app/data/models/demande_model.dart';
import 'package:citoyen_app/data/models/statut_model.dart';
import 'package:citoyen_app/data/repositories/demande_repository.dart';

class DemandeProvider with ChangeNotifier {
  final DemandeRepository _demandeRepository = DemandeRepository();
  List<Demande> _demandes = []; // Liste de toutes les demandes du citoyen
  List<Demande> _validatedDocuments = []; // Liste des documents validés
  List<Statut> _statuts = []; // Liste des statuts disponibles (soumise, en traitement, validée)
  bool _isLoading = false; // État de chargement
  String? _errorMessage; // Message d'erreur

  // Getters pour accéder aux données et à l'état
  List<Demande> get demandes => _demandes;
  List<Demande> get validatedDocuments => _validatedDocuments;
  List<Statut> get statuts => _statuts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupère toutes les demandes effectuées par le citoyen connecté.
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
  Future<bool> createDemande(Map<String, dynamic> demandeData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _demandeRepository.createDemande(demandeData);
      // Actualise la liste des demandes après la création pour que l'UI se mette à jour
      await fetchMyDemandes(); 
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
  Future<void> downloadDocument(int demandeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _demandeRepository.downloadDocument(demandeId);
      // Pas de changement d'état particulier ici car le téléchargement est externe
    } catch (e) {
      _errorMessage = 'Erreur lors du téléchargement du document: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
