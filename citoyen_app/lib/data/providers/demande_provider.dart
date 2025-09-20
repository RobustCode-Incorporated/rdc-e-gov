// lib/data/providers/demande_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';
import 'package:open_filex/open_filex.dart';
import 'package:http_parser/http_parser.dart'; // NOUVEAU

import 'package:citoyen_app/config/app_constants.dart';
import 'package:citoyen_app/data/models/demande_model.dart';
import 'package:citoyen_app/data/models/statut_model.dart';
import 'package:citoyen_app/data/repositories/demande_repository.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';

class DemandeProvider with ChangeNotifier {
  final DemandeRepository _demandeRepository = DemandeRepository();
  List<Demande> _demandes = [];
  List<Demande> _validatedDocuments = [];
  List<Statut> _statuts = [];
  bool _isLoading = false;
  String? _errorMessage;

  final AuthProvider _authProvider;

  DemandeProvider(this._authProvider);

  List<Demande> get demandes => _demandes;
  List<Demande> get validatedDocuments => _validatedDocuments;
  List<Statut> get statuts => _statuts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Méthode pour définir l'état de chargement (utilisée dans le front-end)
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Récupère toutes les demandes effectuées par le citoyen connecté.
  Future<void> fetchMyDemandes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final String? authToken = _authProvider.authToken;
      if (authToken != null) {
        _demandes = await _demandeRepository.getMyDemandes(authToken: authToken);
      } else {
        _errorMessage = 'Token d\'authentification manquant.';
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des demandes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère les documents qui ont été validés pour le citoyen.
  Future<void> fetchValidatedDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final String? authToken = _authProvider.authToken;
      if (authToken != null) {
        // Supposons que votre repository a une méthode pour récupérer spécifiquement les documents validés
        _validatedDocuments = await _demandeRepository.getValidatedDocuments(authToken: authToken);
      } else {
        _errorMessage = 'Token d\'authentification manquant.';
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des documents validés: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère la liste de tous les statuts possibles.
  Future<void> fetchStatuts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final String? authToken = _authProvider.authToken;
      if (authToken != null) {
        _statuts = await _demandeRepository.getStatuts(authToken: authToken);
      } else {
        _errorMessage = 'Token d\'authentification manquant.';
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des statuts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée une nouvelle demande de document.
  Future<bool> createDemande(Map<String, dynamic> demandeData) async {
    setLoading(true);
    try {
      final String? authToken = _authProvider.authToken;
      if (authToken == null) {
        _errorMessage = 'Token d\'authentification manquant. Veuillez vous reconnecter.';
        setLoading(false);
        return false;
      }

      await _demandeRepository.createDemande(demandeData, authToken: authToken);
      await fetchMyDemandes();
      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la création de la demande: $e';
      setLoading(false);
      return false;
    }
  }

  /// Télécharge un fichier image sur le serveur et retourne son URL.
  Future<String?> uploadImage(File imageFile) async {
    setLoading(true);
    final String? authToken = _authProvider.authToken;
    if (authToken == null) {
      _errorMessage = 'Token d\'authentification manquant.';
      setLoading(false);
      return null;
    }

    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/demandes/upload');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $authToken';
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo', // Ce nom de champ doit correspondre à ce qu'attend votre backend
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['url']; // Le backend doit retourner l'URL ici
      } else {
        _errorMessage = 'Échec de l\'upload de la photo: ${response.body}';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'upload de la photo: $e';
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Télécharge et ouvre un document validé.
  Future<void> downloadAndOpenDocument(int demandeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final String? authToken = _authProvider.authToken;
      if (authToken == null) {
        _errorMessage = 'Token d\'authentification manquant.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Demande la permission de stockage pour Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isDenied) {
          _errorMessage = 'Permission de stockage refusée. Impossible de télécharger le document.';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/demandes/$demandeId/download'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        // Utilise getTemporaryDirectory() qui fonctionne sur iOS et Android pour les fichiers temporaires
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/document_$demandeId.pdf';
        
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          _errorMessage = "Impossible d'ouvrir le fichier. Erreur: ${result.message}";
        } else {
          _errorMessage = null; // Réinitialise le message d'erreur en cas de succès
        }
      } else {
        _errorMessage = 'Erreur lors du téléchargement: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion lors du téléchargement: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Télécharge le fichier .pkpass depuis le backend et retourne le chemin local
  Future<String?> addToWallet(int demandeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? authToken = _authProvider.authToken;
      if (authToken == null) {
        _errorMessage = 'Token d\'authentification manquant.';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/demandes/$demandeId/wallet'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/document_$demandeId.pkpass';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          _errorMessage = "Impossible d'ouvrir le fichier Wallet. Erreur: ${result.message}";
        } else {
          _errorMessage = null; // Réinitialise le message d'erreur en cas de succès
        }

        _isLoading = false;
        notifyListeners();
        return filePath;
      } else {
        _errorMessage = 'Erreur lors de la récupération du fichier Wallet: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout au Wallet: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}