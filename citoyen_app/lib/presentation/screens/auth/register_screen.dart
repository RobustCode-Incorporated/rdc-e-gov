import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/models/commune_model.dart';
import 'package:citoyen_app/data/models/province_model.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/commune_provider.dart';
import 'package:citoyen_app/utils/app_router.dart'; // Import pour AppRouter

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _postnomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _lieuNaissanceController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedSexe;
  Province? _selectedProvince;
  Commune? _selectedCommune;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommuneProvider>(context, listen: false).fetchProvinces();
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _postnomController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    _lieuNaissanceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)), // Exemple: propose 20 ans en arrière par défaut
      firstDate: DateTime(1900), // Date la plus ancienne possible
      lastDate: DateTime.now(), // La date la plus récente est aujourd'hui
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
        _dateNaissanceController.text = DateFormat('yyyy-MM-dd').format(picked);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Compte Citoyen'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Consumer2<AuthProvider, CommuneProvider>(
              builder: (context, authProvider, communeProvider, child) {
                return Column(
                  children: [
                    Text(
                      'Inscrivez-vous',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _postnomController,
                      decoration: const InputDecoration(
                        labelText: 'Postnom (Optionnel)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _prenomController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre prénom';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _dateNaissanceController,
                      decoration: InputDecoration(
                        labelText: 'Date de Naissance (AAAA-MM-JJ)',
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      readOnly: true, // Empêche la saisie directe
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner votre date de naissance';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _selectedSexe,
                      decoration: const InputDecoration(
                        labelText: 'Sexe',
                        prefixIcon: Icon(Icons.wc),
                      ),
                      hint: const Text('Sélectionnez votre sexe'),
                      items: <String>['Homme', 'Femme']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSexe = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner votre sexe';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _lieuNaissanceController,
                      decoration: const InputDecoration(
                        labelText: 'Lieu de Naissance',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre lieu de naissance';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    // Sélection de la Province
                    DropdownButtonFormField<Province>(
                      value: _selectedProvince,
                      decoration: InputDecoration(
                        labelText: 'Province de Résidence',
                        prefixIcon: const Icon(Icons.map),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: Text(
                          communeProvider.isLoading && communeProvider.provinces.isEmpty
                              ? 'Chargement des provinces...'
                              : 'Sélectionnez votre province de résidence'
                      ),
                      items: communeProvider.provinces.map((Province province) {
                        return DropdownMenuItem<Province>(
                          value: province,
                          child: Text(province.nom),
                        );
                      }).toList(),
                      onChanged: (Province? newValue) {
                        setState(() {
                          _selectedProvince = newValue;
                          _selectedCommune = null; // Réinitialise la commune
                          if (newValue != null) {
                            communeProvider.fetchCommunesByProvinceId(newValue.id);
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner votre province';
                        }
                        return null;
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16.0),
                    // Sélection de la Commune (dépend de la province)
                    DropdownButtonFormField<Commune>(
                      value: _selectedCommune,
                      decoration: InputDecoration(
                        labelText: 'Commune de Résidence',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: Text(
                          communeProvider.isLoading && _selectedProvince != null
                              ? 'Chargement des communes...'
                              : (_selectedProvince == null
                                  ? 'Sélectionnez d\'abord une province'
                                  : 'Sélectionnez votre commune de résidence')
                      ),
                      items: _selectedProvince == null || communeProvider.communes.isEmpty
                          ? []
                          : communeProvider.communes.map((Commune commune) {
                              return DropdownMenuItem<Commune>(
                                value: commune,
                                child: Text(commune.nom),
                              );
                            }).toList(),
                      onChanged: _selectedProvince == null
                          ? null // Désactivé si aucune province sélectionnée
                          : (Commune? newValue) {
                              setState(() {
                                _selectedCommune = newValue;
                              });
                            },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner votre commune';
                        }
                        return null;
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez confirmer votre mot de passe';
                        }
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24.0),
                    authProvider.isLoading
                        ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_selectedProvince == null || _selectedCommune == null) {
                                  _showSnackBar('Veuillez sélectionner votre province et votre commune.', isError: true);
                                  return;
                                }

                                final citoyenData = {
                                  'nom': _nomController.text,
                                  'postnom': _postnomController.text.isEmpty ? null : _postnomController.text,
                                  'prenom': _prenomController.text,
                                  'dateNaissance': _dateNaissanceController.text,
                                  'sexe': _selectedSexe,
                                  'lieuNaissance': _lieuNaissanceController.text,
                                  'communeId': _selectedCommune!.id,
                                  'password': _passwordController.text,
                                };

                                final success = await authProvider.register(citoyenData);
                                if (success) {
                                  _showSnackBar('Inscription réussie ! Vous êtes maintenant connecté.');
                                  // Naviguer directement vers le tableau de bord
                                  AppRouter.navigateToDashboard(context);
                                } else {
                                  _showSnackBar(authProvider.errorMessage ?? 'Échec de l\'inscription.', isError: true);
                                }
                              }
                            },
                            child: const Text('S\'inscrire'),
                          ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Déjà un compte ?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            AppRouter.navigateToLogin(context); // Utilise AppRouter pour la navigation
                          },
                          child: Text(
                            'Se connecter',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
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
