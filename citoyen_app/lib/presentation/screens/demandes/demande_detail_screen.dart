import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/models/demande_model.dart';
// Suppression de 'dart:convert' car jsonDecode n'est plus nécessaire ici

class DemandeDetailScreen extends StatelessWidget {
  final Demande demande;
  final String statutName; // Nom du statut passé directement pour la simplicité

  const DemandeDetailScreen({
    super.key,
    required this.demande,
    required this.statutName,
  });

  // Fonction utilitaire pour attribuer une couleur au statut
  Color _getStatutColor(int statutId) {
    switch (statutId) {
      case 1: // soumise
        return AppColors.primaryBlue;
      case 2: // en traitement
        return AppColors.orange;
      case 3: // validée
        return AppColors.lightGreen;
      default:
        return AppColors.mediumGray;
    }
  }

  // Widget pour afficher une ligne d'information
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label :',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.brownText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher les données spécifiques à chaque type de demande
  Widget _buildSpecificDemandeDetails(BuildContext context, Demande demande) {
    // CORRECTION : donnesJson est déjà un Map<String, dynamic> si le backend renvoie un objet JSON
    final Map<String, dynamic> donnees = demande.donneesJson; 

    switch (demande.typeDemande) {
      case 'acte_naissance':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations sur l\'enfant', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow(context, 'Nom Enfant', donnees['nomEnfant'] ?? 'N/A'),
            _buildInfoRow(context, 'Postnom Enfant', donnees['postnomEnfant'] ?? 'N/A'),
            _buildInfoRow(context, 'Prénom Enfant', donnees['prenomEnfant'] ?? 'N/A'),
            _buildInfoRow(context, 'Sexe Enfant', donnees['sexeEnfant'] ?? 'N/A'),
            _buildInfoRow(context, 'Date de Naissance Enfant', donnees['dateNaissanceEnfant'] ?? 'N/A'),
            _buildInfoRow(context, 'Lieu de Naissance Enfant', donnees['lieuNaissanceEnfant'] ?? 'N/A'),
            _buildInfoRow(context, 'ID Commune Naissance Enfant', donnees['communeNaissanceEnfantId']?.toString() ?? 'N/A'),
            const SizedBox(height: 16.0),
            Text('Informations sur les parents', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow(context, 'Nom du Père', donnees['nomPere'] ?? 'N/A'),
            _buildInfoRow(context, 'Prénom du Père', donnees['prenomPere'] ?? 'N/A'),
            _buildInfoRow(context, 'Nom de la Mère', donnees['nomMere'] ?? 'N/A'),
            _buildInfoRow(context, 'Prénom de la Mère', donnees['prenomMere'] ?? 'N/A'),
          ],
        );
      case 'carte_identite':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Détails Carte d\'Identité', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow(context, 'Nom du Père', donnees['nomPere'] ?? 'N/A'),
            _buildInfoRow(context, 'Prénom du Père', donnees['prenomPere'] ?? 'N/A'),
            _buildInfoRow(context, 'Nom de la Mère', donnees['nomMere'] ?? 'N/A'),
            _buildInfoRow(context, 'Prénom de la Mère', donnees['prenomMere'] ?? 'N/A'),
            _buildInfoRow(context, 'Profession', donnees['profession'] ?? 'N/A'),
            _buildInfoRow(context, 'État Civil', donnees['etatCivil'] ?? 'N/A'),
            if (donnees['photoIdentiteUrl'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  Text('Photo d\'identité :', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Center(
                    child: Image.network(
                      donnees['photoIdentiteUrl'],
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100, color: AppColors.mediumGray),
                    ),
                  ),
                ],
              ),
          ],
        );
      case 'acte_mariage':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Détails Acte de Mariage', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow(context, 'Nom Conjoint(e)', donnees['nomConjoint'] ?? 'N/A'),
            _buildInfoRow(context, 'Postnom Conjoint(e)', donnees['postnomConjoint'] ?? 'N/A'),
            _buildInfoRow(context, 'Prénom Conjoint(e)', donnees['prenomConjoint'] ?? 'N/A'),
            _buildInfoRow(context, 'Date de Naissance Conjoint(e)', donnees['dateNaissanceConjoint'] ?? 'N/A'),
            _buildInfoRow(context, 'Sexe Conjoint(e)', donnees['sexeConjoint'] ?? 'N/A'),
            _buildInfoRow(context, 'Lieu du Mariage', donnees['lieuMariage'] ?? 'N/A'),
            _buildInfoRow(context, 'Date du Mariage', donnees['dateMariage'] ?? 'N/A'),
            if (donnees['numeroActeMariage'] != null)
              _buildInfoRow(context, 'Numéro Acte Mariage', donnees['numeroActeMariage']),
          ],
        );
      case 'acte_residence':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Détails Acte de Résidence', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow(context, 'Adresse Complète', donnees['adresseComplete'] ?? 'N/A'),
            _buildInfoRow(context, 'Durée de Résidence', donnees['dureeResidence'] ?? 'N/A'),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Données Spécifiques (JSON brut)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            // Affiche le JSON brut si non reconnu (assurez-vous que c'est bien une chaîne si non mappé)
            Text(demande.donneesJson.toString()), 
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statutColor = _getStatutColor(demande.statutId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails ${demande.typeDemande.replaceAll('_', ' ').toUpperCase()}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations Générales de la Demande',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildInfoRow(context, 'ID Demande', demande.id.toString()),
            _buildInfoRow(context, 'Type de Demande', demande.typeDemande.replaceAll('_', ' ').toUpperCase()),
            _buildInfoRow(context, 'Date Soumission', DateFormat('dd/MM/yyyy HH:mm').format(demande.createdAt)),
            _buildInfoRow(context, 'Statut', statutName),
            if (demande.commentaires != null && demande.commentaires!.isNotEmpty)
              _buildInfoRow(context, 'Commentaires Agent', demande.commentaires!),
            const SizedBox(height: 24.0),
            // Affichage des détails spécifiques au type de demande
            _buildSpecificDemandeDetails(context, demande),
          ],
        ),
      ),
    );
  }
}
