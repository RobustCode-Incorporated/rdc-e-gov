import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/models/demande_model.dart';
import 'package:citoyen_app/data/models/statut_model.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';
import 'package:citoyen_app/presentation/screens/demandes/demande_detail_screen.dart';

class DemandesListScreen extends StatefulWidget {
  final int? filterStatusId;

  const DemandesListScreen({super.key, this.filterStatusId});

  @override
  State<DemandesListScreen> createState() => _DemandesListScreenState();
}

class _DemandesListScreenState extends State<DemandesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DemandeProvider>(context, listen: false).fetchMyDemandes();
      Provider.of<DemandeProvider>(context, listen: false).fetchStatuts();
    });
  }

  String _getStatutName(List<Statut> statuts, int statutId) {
    return statuts.firstWhere(
      (s) => s.id == statutId,
      orElse: () => Statut(id: statutId, nom: 'Inconnu'),
    ).nom;
  }

  Color _getStatutColor(int statutId) {
    switch (statutId) {
      case 1:
        return AppColors.primaryBlue;
      case 2:
        return AppColors.orange;
      case 3:
        return AppColors.lightGreen;
      default:
        return AppColors.mediumGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.filterStatusId == null
          ? AppBar(title: const Text('Mes Demandes'))
          : null,
      body: Consumer<DemandeProvider>(
        builder: (context, demandeProvider, child) {
          if (demandeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }

          if (demandeProvider.errorMessage != null) {
            return Center(
              child: Text(
                demandeProvider.errorMessage!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryRed),
              ),
            );
          }

          List<Demande> filteredDemandes = demandeProvider.demandes;
          if (widget.filterStatusId != null) {
            filteredDemandes = filteredDemandes
                .where((demande) => demande.statutId == widget.filterStatusId)
                .toList();
          }

          if (filteredDemandes.isEmpty) {
            return Center(
              child: Text(
                widget.filterStatusId == null
                    ? 'Vous n\'avez pas encore fait de demandes.'
                    : 'Aucune demande avec ce statut.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.brownText),
              ),
            );
          }

          // Affiche la liste des demandes filtrées
          return Expanded( // <-- La correction est ici
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredDemandes.length,
              itemBuilder: (context, index) {
                final demande = filteredDemandes[index];
                final statutName = _getStatutName(demandeProvider.statuts, demande.statutId);
                final statutColor = _getStatutColor(demande.statutId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DemandeDetailScreen(demande: demande, statutName: statutName),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            demande.typeDemande.replaceAll('_', ' ').toUpperCase(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 18, color: AppColors.brownText),
                              const SizedBox(width: 8.0),
                              Text(
                                'Date: ${DateFormat('dd/MM/yyyy').format(demande.createdAt)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.brownText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 18, color: statutColor),
                              const SizedBox(width: 8.0),
                              Text(
                                'Statut: $statutName',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: statutColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (demande.commentaires != null && demande.commentaires!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.comment, size: 18, color: AppColors.darkText),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        'Commentaires de l\'agent:',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.darkText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    demande.commentaires!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.brownText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}