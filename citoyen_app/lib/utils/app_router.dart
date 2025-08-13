import 'package:flutter/material.dart';
import 'package:citoyen_app/data/models/demande_model.dart';
import 'package:citoyen_app/presentation/screens/auth/login_screen.dart';
import 'package:citoyen_app/presentation/screens/auth/register_screen.dart';
import 'package:citoyen_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:citoyen_app/presentation/screens/demandes/demande_detail_screen.dart';
import 'package:citoyen_app/presentation/screens/demandes/demandes_list_screen.dart';
import 'package:citoyen_app/presentation/screens/demandes/form_acte_mariage_screen.dart';
import 'package:citoyen_app/presentation/screens/demandes/form_acte_naissance_screen.dart';
import 'package:citoyen_app/presentation/screens/demandes/form_acte_residence_screen.dart';
import 'package:citoyen_app/presentation/screens/demandes/form_carte_identite_screen.dart';
import 'package:citoyen_app/presentation/screens/my_documents/my_documents_screen.dart';
import 'package:citoyen_app/presentation/screens/profile/profile_screen.dart';

class AppRouter {
  /// Méthode pour naviguer vers l'écran de connexion et supprimer toutes les routes précédentes.
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// Méthode pour naviguer vers l'écran d'inscription.
  static void navigateToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  /// Méthode pour naviguer vers le tableau de bord et supprimer toutes les routes précédentes.
  static void navigateToDashboard(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// Méthode pour naviguer vers l'écran de liste des demandes.
  /// Optionnellement, peut filtrer par statut.
  static void navigateToDemandesList(BuildContext context, {int? filterStatusId}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DemandesListScreen(filterStatusId: filterStatusId)),
    );
  }

  /// Méthode pour naviguer vers l'écran de détails d'une demande.
  static void navigateToDemandeDetail(BuildContext context, Demande demande, String statutName) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DemandeDetailScreen(demande: demande, statutName: statutName)),
    );
  }

  /// Méthode pour naviguer vers l'écran "Mes Documents".
  static void navigateToMyDocuments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MyDocumentsScreen()),
    );
  }

  /// Méthode pour naviguer vers l'écran de profil.
  static void navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  /// Méthode pour naviguer vers le formulaire d'acte de naissance.
  static void navigateToFormActeNaissance(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FormActeNaissanceScreen()),
    );
  }

  /// Méthode pour naviguer vers le formulaire de carte d'identité.
  static void navigateToFormCarteIdentite(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FormCarteIdentiteScreen()),
    );
  }

  /// Méthode pour naviguer vers le formulaire d'acte de mariage.
  static void navigateToFormActeMariage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FormActeMariageScreen()),
    );
  }

  /// Méthode pour naviguer vers le formulaire d'acte de résidence.
  static void navigateToFormActeResidence(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FormActeResidenceScreen()),
    );
  }

  /// Méthode générique pour revenir à l'écran précédent.
  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}
