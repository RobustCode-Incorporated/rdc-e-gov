import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/models/commune_model.dart';
import 'package:citoyen_app/data/models/province_model.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/commune_provider.dart';
import 'package:citoyen_app/utils/app_router.dart';
import 'privacy_policy_screen.dart'; // Assure-toi que ce fichier existe

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _lieuNaissanceController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedSexe;
  Province? _selectedProvince;
  Commune? _selectedCommune;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // ✅ Politique de confidentialité
  bool _acceptedPrivacy = false;

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
    _emailController.dispose();
    _dateNaissanceController.dispose();
    _lieuNaissanceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inscrivez-vous',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24.0),

                    // NOM
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer votre nom' : null,
                    ),
                    const SizedBox(height: 16.0),

                    // POSTNOM
                    TextFormField(
                      controller: _postnomController,
                      decoration: const InputDecoration(
                        labelText: 'Postnom (Optionnel)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // PRENOM
                    TextFormField(
                      controller: _prenomController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer votre prénom' : null,
                    ),
                    const SizedBox(height: 16.0),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse e-mail',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse e-mail';
                        }
                        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Veuillez entrer une adresse e-mail valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // DATE DE NAISSANCE
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
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez sélectionner votre date de naissance' : null,
                    ),
                    const SizedBox(height: 16.0),

                    // SEXE
                    DropdownButtonFormField<String>(
                      value: _selectedSexe,
                      decoration: const InputDecoration(
                        labelText: 'Sexe',
                        prefixIcon: Icon(Icons.wc),
                      ),
                      items: <String>['Homme', 'Femme']
                          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedSexe = value),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez sélectionner votre sexe' : null,
                    ),
                    const SizedBox(height: 16.0),

                    // LIEU DE NAISSANCE
                    TextFormField(
                      controller: _lieuNaissanceController,
                      decoration: const InputDecoration(
                        labelText: 'Lieu de Naissance',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer votre lieu de naissance' : null,
                    ),
                    const SizedBox(height: 16.0),

                    // PROVINCE
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
                      items: communeProvider.provinces
                          .map((province) => DropdownMenuItem(value: province, child: Text(province.nom)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProvince = value;
                          _selectedCommune = null;
                          if (value != null) communeProvider.fetchCommunesByProvinceId(value.id);
                        });
                      },
                      validator: (value) => value == null ? 'Veuillez sélectionner votre province' : null,
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16.0),

                    // COMMUNE
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
                      items: _selectedProvince == null
                          ? []
                          : communeProvider.communes.map((commune) => DropdownMenuItem(value: commune, child: Text(commune.nom))).toList(),
                      onChanged: _selectedProvince == null ? null : (value) => setState(() => _selectedCommune = value),
                      validator: (value) => value == null ? 'Veuillez sélectionner votre commune' : null,
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16.0),

                    // MOT DE PASSE
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                        if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // CONFIRMATION MOT DE PASSE
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Veuillez confirmer votre mot de passe';
                        if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // ✅ Politique de confidentialité moderne
                    InkWell(
                      onTap: () => setState(() => _acceptedPrivacy = !_acceptedPrivacy),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptedPrivacy,
                            onChanged: (value) => setState(() => _acceptedPrivacy = value ?? false),
                          ),
                          Expanded(
                            child: Wrap(
                              children: [
                                const Text('J’ai lu et j’accepte la '),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                                  ),
                                  child: const Text(
                                    'Politique de confidentialité',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const Text('.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // BOUTON S'INSCRIRE
                    authProvider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _acceptedPrivacy
                                  ? () async {
                                      if (_formKey.currentState!.validate()) {
                                        if (_selectedProvince == null || _selectedCommune == null) {
                                          _showSnackBar('Veuillez sélectionner votre province et votre commune.', isError: true);
                                          return;
                                        }

                                        final citoyenData = {
                                          'nom': _nomController.text,
                                          'postnom': _postnomController.text.isEmpty ? null : _postnomController.text,
                                          'prenom': _prenomController.text,
                                          'email': _emailController.text,
                                          'dateNaissance': _dateNaissanceController.text,
                                          'sexe': _selectedSexe,
                                          'lieuNaissance': _lieuNaissanceController.text,
                                          'communeId': _selectedCommune!.id,
                                          'password': _passwordController.text,
                                        };

                                        final success = await authProvider.register(citoyenData);
                                        if (success) {
                                          _showSnackBar('Inscription réussie ! Vous êtes maintenant connecté.');
                                          AppRouter.navigateToDashboard(context);
                                        } else {
                                          _showSnackBar(authProvider.errorMessage ?? 'Échec de l\'inscription.', isError: true);
                                        }
                                      }
                                    }
                                  : null,
                              child: const Text('S\'inscrire'),
                            ),
                          ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Déjà un compte ?', style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => AppRouter.navigateToLogin(context),
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