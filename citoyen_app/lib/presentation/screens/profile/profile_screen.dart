import 'dart:io'; // Pour le type File lors de la sélection d'image
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pour le formatage des dates
import 'package:image_picker/image_picker.dart'; // Pour la sélection d'image
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/models/citoyen_model.dart';
import 'package:citoyen_app/data/models/commune_model.dart'; // Pour le modèle Commune
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/citoyen_provider.dart';
import 'package:citoyen_app/data/providers/commune_provider.dart'; // Pour récupérer le nom de la commune et province
import 'package:citoyen_app/presentation/screens/auth/login_screen.dart'; // Import pour LoginScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile; // Fichier image sélectionné localement

  @override
  void initState() {
    super.initState();
    // Au démarrage de l'écran, charge le profil du citoyen
    // Note: Le profil du citoyen inclut déjà la commune, donc pas besoin de charger les communes séparément pour afficher le nom.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CitoyenProvider>(context, listen: false).fetchProfile();
    });
  }

  // Affiche un SnackBar pour les messages d'information ou d'erreur
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.primaryRed : AppColors.primaryBlue,
      ),
    );
  }

  // Permet à l'utilisateur de choisir une image depuis la galerie ou la caméra
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50); // Qualité réduite pour l'upload
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Met à jour le fichier image localement
      });
      
      // Tente d'uploader la photo de profil via le provider
      final citoyenProvider = Provider.of<CitoyenProvider>(context, listen: false);
      if (citoyenProvider.profile != null) {
        final success = await citoyenProvider.uploadProfilePicture(
            citoyenProvider.profile!.id, pickedFile.path); // Passer l'ID du citoyen et le chemin du fichier
        if (success) {
          _showSnackBar('Photo de profil mise à jour !');
        } else {
          _showSnackBar(citoyenProvider.errorMessage ?? 'Échec de la mise à jour de la photo.', isError: true);
        }
      }
    }
  }

  // Affiche une feuille d'action pour choisir la source de l'image (caméra ou galerie)
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context); // Ferme la feuille d'action
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context); // Ferme la feuille d'action
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CitoyenProvider>( // MODIFIÉ : Nous n'avons plus besoin de CommuneProvider ici
      builder: (context, citoyenProvider, child) {
        final Citoyen? citoyen = citoyenProvider.profile;

        // CORRECTION MAJEURE ICI : La commune est déjà dans l'objet citoyen
        final Commune? citoyenCommune = citoyen?.commune;

        // Affiche un indicateur de chargement si le profil est en cours de récupération
        if (citoyenProvider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
        }

        // Affiche un message d'erreur si le profil n'a pas pu être chargé
        if (citoyen == null) {
          return Center(
            child: Text(
              citoyenProvider.errorMessage ?? 'Impossible de charger le profil.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryRed),
            ),
          );
        }

        // Affiche le contenu du profil
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: AppColors.mediumGray.withOpacity(0.3),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (citoyen.sexe == 'Homme' ? const AssetImage('assets/images/placeholder_male.png') : const AssetImage('assets/images/placeholder_female.png')) as ImageProvider,
                    child: _imageFile == null && 
                           (citoyen.sexe != 'Homme' && citoyen.sexe != 'Femme')
                        ? Icon(Icons.person, size: 80, color: AppColors.primaryBlue.withOpacity(0.7))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context), // Ouvre le sélecteur de source d'image
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Text(
                '${citoyen.prenom} ${citoyen.nom}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'NUC: ${citoyen.numeroUnique}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.brownText,
                ),
              ),
              const SizedBox(height: 32.0),
              _buildProfileInfoRow(
                  context, 'Date de Naissance', DateFormat('dd/MM/yyyy').format(citoyen.dateNaissance)),
              _buildProfileInfoRow(context, 'Sexe', citoyen.sexe),
              _buildProfileInfoRow(context, 'Lieu de Naissance', citoyen.lieuNaissance),
              _buildProfileInfoRow(context, 'Commune de Résidence', citoyenCommune?.nom ?? 'N/A'),
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
                onPressed: () {
                  _showSnackBar('Fonctionnalité d\'édition de profil à implémenter.');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Modifier le profil'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () {
                  _showSnackBar('Fonctionnalité de changement de mot de passe à implémenter.');
                },
                icon: const Icon(Icons.vpn_key),
                label: const Text('Changer le mot de passe'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.accentGreen,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primaryRed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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