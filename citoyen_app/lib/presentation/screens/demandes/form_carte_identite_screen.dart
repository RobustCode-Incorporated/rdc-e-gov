// lib/screens/demandes/form_carte_identite_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';

class FormCarteIdentiteScreen extends StatefulWidget {
  const FormCarteIdentiteScreen({super.key});

  @override
  State<FormCarteIdentiteScreen> createState() => _FormCarteIdentiteScreenState();
}

class _FormCarteIdentiteScreenState extends State<FormCarteIdentiteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomPereController = TextEditingController();
  final TextEditingController _prenomPereController = TextEditingController();
  final TextEditingController _nomMereController = TextEditingController();
  final TextEditingController _prenomMereController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  String? _selectedEtatCivil;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nomPereController.dispose();
    _prenomPereController.dispose();
    _nomMereController.dispose();
    _prenomMereController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 50,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _pickedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 50,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _pickedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
        appBar: AppBar(title: const Text('Demande Carte d\'Identité')),
        body: const Center(child: Text('Veuillez vous connecter pour faire une demande.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande Carte d\'Identité'),
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
                      'Informations Générales',
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
                    _buildInfoDisplayRow(context, 'Lieu de Naissance', citoyen.lieuNaissance),
                    _buildInfoDisplayRow(context, 'Sexe', citoyen.sexe),
                    const SizedBox(height: 24.0),
                    Text(
                      'Informations Complémentaires',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _nomPereController,
                      decoration: const InputDecoration(labelText: 'Nom du Père', prefixIcon: Icon(Icons.person)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer le nom du père' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _prenomPereController,
                      decoration: const InputDecoration(labelText: 'Prénom du Père', prefixIcon: Icon(Icons.person)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer le prénom du père' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _nomMereController,
                      decoration: const InputDecoration(labelText: 'Nom de la Mère', prefixIcon: Icon(Icons.person)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer le nom de la mère' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _prenomMereController,
                      decoration: const InputDecoration(labelText: 'Prénom de la Mère', prefixIcon: Icon(Icons.person)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer le prénom de la mère' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _professionController,
                      decoration: const InputDecoration(labelText: 'Profession', prefixIcon: Icon(Icons.work)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer votre profession' : null,
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'État Civil',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedEtatCivil,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.favorite)),
                      hint: const Text('Sélectionnez votre état civil'),
                      items: <String>['Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf(ve)']
                          .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                          .toList(),
                      onChanged: (String? newValue) => setState(() => _selectedEtatCivil = newValue),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez sélectionner votre état civil' : null,
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'Photo d\'Identité (obligatoire)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: _pickedImage == null
                          ? Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                color: AppColors.mediumGray.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.mediumGray),
                              ),
                              child: Icon(Icons.image, size: 80, color: AppColors.mediumGray),
                            )
                          : Image.file(_pickedImage!, height: 150, width: 150, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Choisir une photo'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    demandeProvider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_pickedImage == null) {
                                  _showSnackBar('Veuillez ajouter une photo d\'identité.', isError: true);
                                  return;
                                }
                                final photoUrl = await demandeProvider.uploadImage(_pickedImage!);
                                if (photoUrl == null) {
                                  _showSnackBar(demandeProvider.errorMessage ?? 'Échec de l\'upload de la photo.', isError: true);
                                  return;
                                }

                                final donneesCarteIdentite = {
                                  'nomPere': _nomPereController.text,
                                  'prenomPere': _prenomPereController.text,
                                  'nomMere': _nomMereController.text,
                                  'prenomMere': _prenomMereController.text,
                                  'profession': _professionController.text,
                                  'etatCivil': _selectedEtatCivil,
                                  'photoUrl': photoUrl,
                                  'nucCitoyen': citoyen.numeroUnique,
                                };

                                final success = await demandeProvider.createDemande({
                                  'citoyenId': citoyen.id,
                                  'communeId': citoyen.commune.id,
                                  'typeDemande': 'carte_identite',
                                  'donneesJson': donneesCarteIdentite,
                                  'statutId': 1,
                                });

                                if (success) {
                                  _showSnackBar('Demande de carte d\'identité soumise avec succès !');
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