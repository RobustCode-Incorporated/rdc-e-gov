import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';

class FormActeMariageScreen extends StatefulWidget {
  const FormActeMariageScreen({super.key});

  @override
  State<FormActeMariageScreen> createState() => _FormActeMariageScreenState();
}

class _FormActeMariageScreenState extends State<FormActeMariageScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomConjointController = TextEditingController();
  final TextEditingController _postnomConjointController = TextEditingController();
  final TextEditingController _prenomConjointController = TextEditingController();
  final TextEditingController _dateNaissanceConjointController = TextEditingController();
  final TextEditingController _lieuMariageController = TextEditingController();
  final TextEditingController _dateMariageController = TextEditingController();

  String? _selectedSexeConjoint;

  @override
  void dispose() {
    _nomConjointController.dispose();
    _postnomConjointController.dispose();
    _prenomConjointController.dispose();
    _dateNaissanceConjointController.dispose();
    _lieuMariageController.dispose();
    _dateMariageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
        appBar: AppBar(title: const Text('Demande Acte de Mariage')),
        body: const Center(child: Text('Veuillez vous connecter pour faire une demande.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande Acte de Mariage'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Consumer<DemandeProvider>(
              builder: (context, demandeProvider, child) {
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
                    const SizedBox(height: 24.0),
                    Text(
                      'Informations sur le conjoint(e)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _nomConjointController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du conjoint(e)',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom du conjoint(e)';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _postnomConjointController,
                      decoration: const InputDecoration(
                        labelText: 'Postnom du conjoint(e) (Optionnel)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _prenomConjointController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom du conjoint(e)',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le prénom du conjoint(e)';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _dateNaissanceConjointController,
                      decoration: InputDecoration(
                        labelText: 'Date de Naissance du conjoint(e) (AAAA-MM-JJ)',
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _selectDate(context, _dateNaissanceConjointController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateNaissanceConjointController),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner la date de naissance du conjoint(e)';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _selectedSexeConjoint,
                      decoration: const InputDecoration(
                        labelText: 'Sexe du conjoint(e)',
                        prefixIcon: Icon(Icons.wc),
                      ),
                      hint: const Text('Sélectionnez le sexe du conjoint(e)'),
                      items: <String>['Homme', 'Femme']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSexeConjoint = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner le sexe du conjoint(e)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'Informations du mariage',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _lieuMariageController,
                      decoration: const InputDecoration(
                        labelText: 'Lieu du Mariage',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le lieu du mariage';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _dateMariageController,
                      decoration: InputDecoration(
                        labelText: 'Date du Mariage (AAAA-MM-JJ)',
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _selectDate(context, _dateMariageController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateMariageController),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner la date du mariage';
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
                                final donneesActeMariage = {
                                  'nomConjoint': _nomConjointController.text,
                                  'postnomConjoint': _postnomConjointController.text.isEmpty ? null : _postnomConjointController.text,
                                  'prenomConjoint': _prenomConjointController.text,
                                  'dateNaissanceConjoint': _dateNaissanceConjointController.text,
                                  'sexeConjoint': _selectedSexeConjoint,
                                  'lieuMariage': _lieuMariageController.text,
                                  'dateMariage': _dateMariageController.text,
                                  // Le 'numeroActeMariage' sera généré automatiquement par le backend lors de la validation
                                };

                                final success = await demandeProvider.createDemande({
                                  'citoyenId': citoyen.id,
                                  'communeId': citoyen.commune.id,
                                  'typeDemande': 'acte_mariage',
                                  'donneesJson': donneesActeMariage,
                                  'statutId': 1, // 'soumise' par défaut
                                });

                                if (success) {
                                  _showSnackBar('Demande d\'acte de mariage soumise avec succès !');
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

  // Helper pour afficher les infos pré-remplies
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
