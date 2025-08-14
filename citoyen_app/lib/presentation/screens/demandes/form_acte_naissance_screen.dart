import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/models/commune_model.dart';
import 'package:citoyen_app/data/models/province_model.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/commune_provider.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';
import 'package:citoyen_app/utils/app_router.dart';

class FormActeNaissanceScreen extends StatefulWidget {
  const FormActeNaissanceScreen({super.key});

  @override
  State<FormActeNaissanceScreen> createState() => _FormActeNaissanceScreenState();
}

class _FormActeNaissanceScreenState extends State<FormActeNaissanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomEnfantController = TextEditingController();
  final TextEditingController _postnomEnfantController = TextEditingController();
  final TextEditingController _prenomEnfantController = TextEditingController();
  final TextEditingController _enfantDateNaissanceController = TextEditingController();
  final TextEditingController _enfantLieuNaissanceController = TextEditingController();
  final TextEditingController _nomPereController = TextEditingController();
  final TextEditingController _prenomPereController = TextEditingController();
  final TextEditingController _nomMereController = TextEditingController();
  final TextEditingController _prenomMereController = TextEditingController();
  
  String? _selectedSexeEnfant;
  Province? _selectedProvinceNaissanceEnfant;
  Commune? _selectedCommuneNaissanceEnfant;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommuneProvider>(context, listen: false).fetchProvinces();
    });
  }

  @override
  void dispose() {
    _nomEnfantController.dispose();
    _postnomEnfantController.dispose();
    _prenomEnfantController.dispose();
    _enfantDateNaissanceController.dispose();
    _enfantLieuNaissanceController.dispose();
    _nomPereController.dispose();
    _prenomPereController.dispose();
    _nomMereController.dispose();
    _prenomMereController.dispose();
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.primaryRed : AppColors.primaryBlue,
        ),
      );
    }
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
                      controller: _nomEnfantController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'enfant',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom de l\'enfant';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _postnomEnfantController,
                      decoration: const InputDecoration(
                        labelText: 'Postnom de l\'enfant (Optionnel)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _prenomEnfantController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom de l\'enfant',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le prénom de l\'enfant';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _selectedSexeEnfant,
                      decoration: const InputDecoration(
                        labelText: 'Sexe de l\'enfant',
                        prefixIcon: Icon(Icons.wc),
                      ),
                      hint: const Text('Sélectionnez le sexe de l\'enfant'),
                      items: <String>['Homme', 'Femme']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSexeEnfant = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner le sexe de l\'enfant';
                        }
                        return null;
                      },
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
                          _selectedCommuneNaissanceEnfant = null;
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
                          ? null
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
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_selectedProvinceNaissanceEnfant == null || _selectedCommuneNaissanceEnfant == null) {
                                  _showSnackBar('Veuillez sélectionner la province et la commune de naissance de l\'enfant.', isError: true);
                                  return;
                                }
                                if (_selectedSexeEnfant == null) {
                                  _showSnackBar('Veuillez sélectionner le sexe de l\'enfant.', isError: true);
                                  return;
                                }

                                setState(() {
                                  _isSubmitting = true;
                                });

                                try {
                                  final donneesActeNaissance = {
                                    'nomEnfant': _nomEnfantController.text,
                                    'postnomEnfant': _postnomEnfantController.text.isEmpty ? null : _postnomEnfantController.text,
                                    'prenomEnfant': _prenomEnfantController.text,
                                    'sexeEnfant': _selectedSexeEnfant,
                                    'dateNaissanceEnfant': _enfantDateNaissanceController.text,
                                    'lieuNaissanceEnfant': _enfantLieuNaissanceController.text,
                                    'provinceNaissanceEnfantId': _selectedProvinceNaissanceEnfant!.id,
                                    'communeNaissanceEnfantId': _selectedCommuneNaissanceEnfant!.id,
                                    'nomPere': _nomPereController.text,
                                    'prenomPere': _prenomPereController.text,
                                    'nomMere': _nomMereController.text,
                                    'prenomMere': _prenomMereController.text,
                                  };

                                  final success = await demandeProvider.createDemande({
                                    'citoyenId': citoyen.id,
                                    'communeId': citoyen.commune.id,
                                    'typeDemande': 'acte_naissance',
                                    'donneesJson': jsonEncode(donneesActeNaissance),
                                    'statutId': 1,
                                  }); // Le token est retiré ici

                                  if (mounted) {
                                    if (success) {
                                      _showSnackBar('Demande d\'acte de naissance soumise avec succès !');
                                      Navigator.of(context).pop();
                                    } else {
                                      _showSnackBar(demandeProvider.errorMessage ?? 'Échec de la soumission de la demande.', isError: true);
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    _showSnackBar('Une erreur est survenue: $e', isError: true);
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isSubmitting = false;
                                    });
                                  }
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