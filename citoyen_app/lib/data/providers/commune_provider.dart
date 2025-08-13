import 'package:flutter/material.dart';
import 'package:citoyen_app/data/models/commune_model.dart';
import 'package:citoyen_app/data/models/province_model.dart';
import 'package:citoyen_app/data/repositories/commune_repository.dart';
import 'package:citoyen_app/utils/api_helper.dart'; // Importez ApiHelper

class CommuneProvider with ChangeNotifier {
  final CommuneRepository _communeRepository = CommuneRepository();
  final ApiHelper _apiHelper = ApiHelper(); // Instance de ApiHelper pour supprimer le token

  List<Province> _provinces = [];
  List<Commune> _communes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Province> get provinces => _provinces;
  List<Commune> get communes => _communes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupère toutes les provinces disponibles.
  /// Met à jour la liste des provinces et notifie les écouteurs.
  Future<void> fetchProvinces() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // DEBUG HACK: Efface le token avant de faire la requête provinces
      // À retirer une fois que le problème 401 est résolu pour les provinces
      await _apiHelper.deleteAuthToken(); 
      print('DEBUG CommuneProvider: Token effacé avant fetchProvinces.');

      print('DEBUG CommuneProvider: Début du fetchProvinces.');
      _provinces = await _communeRepository.getProvinces();
      print('DEBUG CommuneProvider: ${_provinces.length} provinces chargées.');
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des provinces: $e';
      print('DEBUG CommuneProvider ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère les communes associées à un ID de province spécifique.
  /// Met à jour la liste des communes et notifie les écouteurs.
  Future<void> fetchCommunesByProvinceId(int provinceId) async {
    _isLoading = true;
    _errorMessage = null;
    _communes = []; // Efface les anciennes communes lors du changement de province
    notifyListeners();
    try {
      print('DEBUG CommuneProvider: Début du fetchCommunesByProvinceId pour Province ID: $provinceId.');
      _communes = await _communeRepository.getCommunesByProvinceId(provinceId);
      print('DEBUG CommuneProvider: ${_communes.length} communes chargées pour Province ID: $provinceId.');
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des communes: $e';
      print('DEBUG CommuneProvider ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
