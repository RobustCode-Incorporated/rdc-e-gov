import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/models/demande_model.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class MyDocumentsScreen extends StatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  // Liste des documents pour lesquels on ne veut pas proposer “Ajouter au Wallet”
  static const List<String> _excludedDocs = [
    'acte_residence',
    'acte_mariage',
    'acte_naissance',
  ];

  @override
  void initState() {
    super.initState();
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

  Future<void> _addToWallet(Demande document, DemandeProvider provider) async {
    if (!Platform.isIOS) {
      _showSnackBar('Apple Wallet n’est disponible que sur iOS', isError: true);
      return;
    }

    _showSnackBar('Ajout au Wallet en cours...');
    try {
      final filePath = await provider.addToWallet(document.id);
      if (filePath != null) {
        await OpenFilex.open(filePath);
        _showSnackBar('Carte ajoutée à votre Wallet avec succès !');
      } else {
        _showSnackBar('Erreur lors de l’ajout au Wallet', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur : $e', isError: true);
    }
  }

  bool _isExcludedDocument(String typeDemande) {
    // Comparaison en minuscule pour éviter les problèmes de casse
    return _excludedDocs.contains(typeDemande.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Documents'),
      ),
      body: Consumer<DemandeProvider>(
        builder: (context, demandeProvider, child) {
          if (demandeProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (demandeProvider.errorMessage != null) {
            return Center(
              child: Text(
                demandeProvider.errorMessage!,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.primaryRed),
              ),
            );
          }

          if (demandeProvider.validatedDocuments.isEmpty) {
            return Center(
              child: Text(
                'Aucun document validé pour l\'instant.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.brownText),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: demandeProvider.validatedDocuments.length,
            itemBuilder: (context, index) {
              final document = demandeProvider.validatedDocuments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.typeDemande
                            .replaceAll('_', ' ')
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: AppColors.brownText),
                          const SizedBox(width: 8.0),
                          Text(
                            'Date de validation: ${DateFormat('dd/MM/yyyy').format(document.createdAt)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.brownText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.description,
                              size: 18, color: AppColors.primaryBlue),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Télécharger / Voir le document',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.file_download,
                                color: AppColors.primaryBlue, size: 24),
                            onPressed: () async {
                              _showSnackBar('Téléchargement en cours...');
                              await demandeProvider
                                  .downloadAndOpenDocument(document.id);
                              if (demandeProvider.errorMessage != null) {
                                _showSnackBar(demandeProvider.errorMessage!,
                                    isError: true);
                              } else {
                                _showSnackBar(
                                    'Document téléchargé et ouvert avec succès.');
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // On affiche le bouton “Ajouter au Wallet” uniquement si iOS et le document **n’est pas** exclu
                      if (Platform.isIOS &&
                          !_isExcludedDocument(document.typeDemande))
                        Row(
                          children: [
                            Icon(Icons.credit_card,
                                size: 18, color: AppColors.primaryGreen),
                            const SizedBox(width: 8.0),
                            ElevatedButton(
                              onPressed: () => _addToWallet(document, demandeProvider),
                              child: const Text('Ajouter au Wallet'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                    ],
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