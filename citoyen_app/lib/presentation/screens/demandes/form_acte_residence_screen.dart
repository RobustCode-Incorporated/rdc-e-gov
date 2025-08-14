import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';

class FormActeResidenceScreen extends StatefulWidget {
  const FormActeResidenceScreen({super.key});

  @override
  State<FormActeResidenceScreen> createState() => _FormActeResidenceScreenState();
}

class _FormActeResidenceScreenState extends State<FormActeResidenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adresseCompleteController = TextEditingController();
  final TextEditingController _dureeResidenceController = TextEditingController();

  @override
  void dispose() {
    _adresseCompleteController.dispose();
    _dureeResidenceController.dispose();
    super.dispose();
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
    final authProvider = Provider.of<AuthProvider>(context);
    final citoyen = authProvider.currentCitoyen;

    if (citoyen == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Demande Acte de Résidence')),
        body: const Center(child: Text('Veuillez vous connecter pour faire une demande.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande Acte de Résidence'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            // MODIFICATION: Utilisez Consumer<DemandeProvider> car la commune est déjà dans le citoyen
            child: Consumer<DemandeProvider>(
              builder: (context, demandeProvider, child) {
                // CORRECTION: Accédez directement à l'objet Commune du citoyen
                final currentCommune = citoyen.commune;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations du demandeur',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildInfoDisplayRow(context, 'Nom', citoyen.nom),
                    _buildInfoDisplayRow(context, 'Postnom', citoyen.postnom),
                    _buildInfoDisplayRow(context, 'Prénom', citoyen.prenom),
                    _buildInfoDisplayRow(context, 'Date de Naissance', DateFormat('dd/MM/yyyy').format(citoyen.dateNaissance)),
                    _buildInfoDisplayRow(context, 'Sexe', citoyen.sexe),
                    // CORRECTION: Utilisez l'objet commune directement
                    _buildInfoDisplayRow(context, 'Commune de Résidence', currentCommune.nom),
                    const SizedBox(height: 24.0),
                    Text(
                      'Détails de la résidence',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _adresseCompleteController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse Complète (Quartier, Avenue, Numéro)',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse complète';
                        }
                        return null;
                      },
                      maxLines: 3,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _dureeResidenceController,
                      decoration: const InputDecoration(
                        labelText: 'Durée de la Résidence (Ex: 5 ans, Depuis 2020)',
                        prefixIcon: Icon(Icons.timelapse),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la durée de votre résidence';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24.0),
                    demandeProvider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final donneesActeResidence = {
                                  'adresseComplete': _adresseCompleteController.text,
                                  'dureeResidence': _dureeResidenceController.text,
                                };

                                final success = await demandeProvider.createDemande({
                                  'citoyenId': citoyen.id,
                                  // CORRECTION: Accédez à l'ID de la commune via l'objet
                                  'communeId': citoyen.commune.id,
                                  'typeDemande': 'acte_residence',
                                  'donneesJson': donneesActeResidence,
                                  'statutId': 1, // 'soumise' par défaut
                                });

                                if (success) {
                                  _showSnackBar('Demande d\'acte de résidence soumise avec succès !');
                                  Navigator.of(context).pop();
                                } else {
                                  _showSnackBar(demandeProvider.errorMessage ?? 'Échec de la soumission de la demande.', isError: true);
                                }
                              }
                            },
                            child: const Text('Soumettre la demande'),
                          ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoDisplayRow(BuildContext context, String label, String value) {
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
}