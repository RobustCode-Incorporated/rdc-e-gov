// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:citoyen_app/config/app_config.dart'; // Assurez-vous d'importer votre fichier de configuration

class ApiService {
  // Initialisation de Dio avec les options de base
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl, // URL de base de votre API depuis app_config.dart
    connectTimeout: const Duration(seconds: 10), // Temps maximum pour établir la connexion (10 secondes)
    receiveTimeout: const Duration(seconds: 10), // Temps maximum pour recevoir la réponse (10 secondes)
  ));

  /// Méthode générique pour les requêtes GET.
  /// Prend en paramètre le chemin de l'API (ex: '/demandes/my').
  /// Peut optionnellement prendre un `authToken` pour les requêtes authentifiées.
  Future<dynamic> get(String path, {String? authToken}) async {
    try {
      // Configuration des en-têtes d'autorisation si un jeton est fourni
      final options = Options(
        headers: authToken != null ? {'Authorization': 'Bearer $authToken'} : null,
      );

      final response = await _dio.get(path, options: options);
      return response.data; // Retourne les données de la réponse
    } on DioException catch (e) {
      // Gestion spécifique des erreurs Dio (erreurs réseau, 4xx, 5xx, etc.)
      // Tente de récupérer le message d'erreur du backend ou fournit un message générique
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: e.error,
        message: e.response?.data['message'] ?? 'Erreur de connexion au serveur.',
      );
    } catch (e) {
      // Gestion des autres types d'erreurs inattendues
      rethrow; // Relance l'exception pour qu'elle soit gérée plus haut dans la chaîne d'appels
    }
  }

  /// Méthode générique pour les requêtes POST.
  /// Prend en paramètre le chemin de l'API et les données à envoyer.
  /// Peut optionnellement prendre un `authToken` pour les requêtes authentifiées.
  Future<dynamic> post(String path, dynamic data, {String? authToken}) async {
    try {
      // Configuration des en-têtes d'autorisation si un jeton est fourni
      final options = Options(
        headers: authToken != null ? {'Authorization': 'Bearer $authToken'} : null,
      );

      final response = await _dio.post(path, data: data, options: options);
      return response.data; // Retourne les données de la réponse
    } on DioException catch (e) {
      // Gestion spécifique des erreurs Dio
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: e.error,
        message: e.response?.data['message'] ?? 'Erreur de connexion au serveur.',
      );
    } catch (e) {
      rethrow; // Relance l'exception
    }
  }

  // Vous pouvez ajouter d'autres méthodes HTTP (PUT, DELETE, PATCH, etc.) ici
  // de manière similaire, en adaptant le type de requête et les paramètres.
}
