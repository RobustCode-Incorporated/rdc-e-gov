import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/models/demande_model.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';

class MyDocumentsScreen extends StatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  @override
  void initState() {
    super.initState();
    // Au démarrage de l'écran, on demande au provider de charger les documents validés
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DemandeProvider>(context, listen: false).fetchValidatedDocuments();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.primaryRed : AppColors.primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Documents'),
      ),
      body: Consumer<DemandeProvider>(
        builder: (context, demandeProvider, child) {
          // Affiche un indicateur de chargement si les données sont en cours de récupération
          if (demandeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }

          // Affiche un message d'erreur si la récupération a échoué
          if (demandeProvider.errorMessage != null) {
            return Center(
              child: Text(
                demandeProvider.errorMessage!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryRed),
              ),
            );
          }

          // Affiche un message si aucun document validé n'est trouvé
          if (demandeProvider.validatedDocuments.isEmpty) {
            return Center(
              child: Text(
                'Aucun document validé pour l\'instant.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.brownText),
              ),
            );
          }

          // Affiche la liste des documents validés sous forme de cartes
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: demandeProvider.validatedDocuments.length,
            itemBuilder: (context, index) {
              final document = demandeProvider.validatedDocuments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: InkWell(
                  // lib/screens/my_documents_screen.dart
// ... imports existants

// ... le reste du code
                  onTap: () async {
                    _showSnackBar('Téléchargement en cours...');
                    
                    // Appel de la nouvelle méthode du provider
                    await demandeProvider.downloadAndOpenDocument(document.id);

                    // Affiche un message de succès ou d'erreur après l'opération
                    if (demandeProvider.errorMessage != null) {
                      _showSnackBar(demandeProvider.errorMessage!, isError: true);
                    } else {
                      _showSnackBar('Document téléchargé et ouvert avec succès.');
                    }
                  },
// ... le reste du code
                  borderRadius: BorderRadius.circular(12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.typeDemande.replaceAll('_', ' ').toUpperCase(), // Nom du type de document
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: AppColors.brownText),
                            const SizedBox(width: 8.0),
                            Text(
                              // Assumons que createdAt est la date de validation ou utilise une nouvelle propriété si ton modèle Demande a une dateValidation
                              'Date de validation: ${DateFormat('dd/MM/yyyy').format(document.createdAt)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.brownText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.description, size: 18, color: AppColors.primaryBlue),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                'Télécharger / Voir le document',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.file_download, size: 24, color: AppColors.primaryBlue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
