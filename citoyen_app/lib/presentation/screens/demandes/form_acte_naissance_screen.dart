import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/models/commune_model.dart';
import 'package:citoyen_app/data/models/province_model.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/commune_provider.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';

class FormActeNaissanceScreen extends StatefulWidget {
  const FormActeNaissanceScreen({super.key});

  @override
  State<FormActeNaissanceScreen> createState() => _FormActeNaissanceScreenState();
}

class _FormActeNaissanceScreenState extends State<FormActeNaissanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomPereController = TextEditingController();
  final TextEditingController _prenomPereController = TextEditingController();
  final TextEditingController _nomMereController = TextEditingController();
  final TextEditingController _prenomMereController = TextEditingController();
  final TextEditingController _enfantDateNaissanceController = TextEditingController();
  final TextEditingController _enfantLieuNaissanceController = TextEditingController(); // Sera un champ de texte libre

  Province? _selectedProvinceNaissanceEnfant; // Pour la province de naissance de l'enfant
  Commune? _selectedCommuneNaissanceEnfant; // Pour la commune de naissance de l'enfant

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Charge toutes les provinces pour la sélection du lieu de naissance de l'enfant
      Provider.of<CommuneProvider>(context, listen: false).fetchProvinces();
    });
  }

  @override
  void dispose() {
    _nomPereController.dispose();
    _prenomPereController.dispose();
    _nomMereController.dispose();
    _prenomMereController.dispose();
    _enfantDateNaissanceController.dispose();
    _enfantLieuNaissanceController.dispose();
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
              primary: AppColors.primaryBlue, // Couleur des sélections
              onPrimary: Colors.white, // Couleur du texte sur les sélections
              onSurface: AppColors.darkText, // Couleur du texte sur le calendrier
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue, // Couleur des boutons Annuler/OK
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
        appBar: AppBar(title: const Text('Demande Acte de Naissance')),
        body: const Center(child: Text('Veuillez vous connecter pour faire une demande.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande Acte de Naissance'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Consumer2<DemandeProvider, CommuneProvider>(
              builder: (context, demandeProvider, communeProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations sur l\'enfant',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _enfantDateNaissanceController,
                      decoration: InputDecoration(
                        labelText: 'Date de Naissance de l\'enfant (AAAA-MM-JJ)',
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _selectDate(context, _enfantDateNaissanceController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _enfantDateNaissanceController),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner la date de naissance de l\'enfant';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _enfantLieuNaissanceController,
                      decoration: const InputDecoration(
                        labelText: 'Lieu de Naissance de l\'enfant',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le lieu de naissance de l\'enfant';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    // Sélection de la Province pour le lieu de naissance de l'enfant
                    DropdownButtonFormField<Province>(
                      decoration: InputDecoration(
                        labelText: 'Province de Naissance de l\'enfant',
                        prefixIcon: const Icon(Icons.map),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: Text(
                          communeProvider.isLoading && communeProvider.provinces.isEmpty
                              ? 'Chargement des provinces...'
                              : 'Sélectionnez la province de naissance'
                      ),
                      value: _selectedProvinceNaissanceEnfant,
                      items: communeProvider.provinces.map((Province province) {
                        return DropdownMenuItem<Province>(
                          value: province,
                          child: Text(province.nom),
                        );
                      }).toList(),
                      onChanged: (Province? newValue) {
                        setState(() {
                          _selectedProvinceNaissanceEnfant = newValue;
                          _selectedCommuneNaissanceEnfant = null; // Réinitialise la commune
                          if (newValue != null) {
                            communeProvider.fetchCommunesByProvinceId(newValue.id);
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner la province de naissance';
                        }
                        return null;
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16.0),
                    // Sélection de la Commune de Naissance de l'enfant
                    DropdownButtonFormField<Commune>(
                      value: _selectedCommuneNaissanceEnfant,
                      decoration: InputDecoration(
                        labelText: 'Commune de Naissance de l\'enfant',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: Text(
                          communeProvider.isLoading && _selectedProvinceNaissanceEnfant != null
                              ? 'Chargement des communes...'
                              : (_selectedProvinceNaissanceEnfant == null
                                  ? 'Sélectionnez d\'abord une province'
                                  : 'Sélectionnez la commune de naissance')
                      ),
                      items: communeProvider.communes.map((Commune commune) {
                        return DropdownMenuItem<Commune>(
                          value: commune,
                          child: Text(commune.nom),
                        );
                      }).toList(),
                      onChanged: _selectedProvinceNaissanceEnfant == null
                          ? null // Désactivé si aucune province sélectionnée
                          : (Commune? newValue) {
                              setState(() {
                                _selectedCommuneNaissanceEnfant = newValue;
                              });
                            },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner la commune de naissance';
                        }
                        return null;
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'Informations sur les parents',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _nomPereController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du Père',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom du père';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _prenomPereController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom du Père',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le prénom du père';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _nomMereController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la Mère',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom de la mère';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _prenomMereController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom de la Mère',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le prénom de la mère';
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
                                if (_selectedProvinceNaissanceEnfant == null || _selectedCommuneNaissanceEnfant == null) {
                                  _showSnackBar('Veuillez sélectionner la province et la commune de naissance de l\'enfant.', isError: true);
                                  return;
                                }

                                final donneesActeNaissance = {
                                  'nomPere': _nomPereController.text,
                                  'prenomPere': _prenomPereController.text,
                                  'nomMere': _nomMereController.text,
                                  'prenomMere': _prenomMereController.text,
                                  'dateNaissanceEnfant': _enfantDateNaissanceController.text,
                                  'lieuNaissanceEnfant': _enfantLieuNaissanceController.text,
                                  'provinceNaissanceEnfantId': _selectedProvinceNaissanceEnfant!.id,
                                  'communeNaissanceEnfantId': _selectedCommuneNaissanceEnfant!.id,
                                };

                                final success = await demandeProvider.createDemande({
                                  'citoyenId': citoyen.id, // ID du citoyen connecté
                                  'communeId': citoyen.communeId, // Commune du citoyen connecté (pour association)
                                  'typeDemande': 'acte_naissance',
                                  'donneesJson': donneesActeNaissance,
                                  'statutId': 1, // 'soumise' par défaut
                                });

                                if (success) {
                                  _showSnackBar('Demande d\'acte de naissance soumise avec succès !');
                                  Navigator.of(context).pop(); // Revenir à la liste des demandes ou dashboard
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
}
