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
    // Au démarrage de l'écran, charge le profil du citoyen et les provinces/communes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CitoyenProvider>(context, listen: false).fetchProfile();
      // Charger les provinces est nécessaire pour ensuite charger les communes et trouver le nom de la commune du citoyen
      Provider.of<CommuneProvider>(context, listen: false).fetchProvinces();
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
    return Consumer2<CitoyenProvider, CommuneProvider>(
      builder: (context, citoyenProvider, communeProvider, child) {
        final Citoyen? citoyen = citoyenProvider.profile;
        // Tente de trouver la commune du citoyen dans la liste des communes chargées
        final Commune? citoyenCommune = communeProvider.communes.isNotEmpty && citoyen != null
            ? communeProvider.communes.firstWhere(
                (commune) => commune.id == citoyen.communeId,
                orElse: () => Commune(id: -1, nom: 'Inconnue', code: '', provinceId: -1), // Valeur par défaut si non trouvée
              )
            : null;

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
                    // Si une image locale a été sélectionnée, utilisez-la
                    // Sinon, si le citoyen a une URL de photo de profil (à ajouter au modèle Citoyen), utilisez NetworkImage
                    // Sinon, utilisez des images de placeholder par défaut
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        // Si le modèle Citoyen avait une propriété 'profileImageUrl' :
                        // : citoyen.profileImageUrl != null && citoyen.profileImageUrl!.isNotEmpty
                        //     ? NetworkImage(citoyen.profileImageUrl!)
                            : (citoyen.sexe == 'Homme' ? const AssetImage('assets/images/placeholder_male.png') : const AssetImage('assets/images/placeholder_female.png')) as ImageProvider,
                    child: _imageFile == null && 
                           // Vérifiez aussi si citoyen.profileImageUrl est vide/null ici
                           (citoyen.sexe != 'Homme' && citoyen.sexe != 'Femme') // Afficher l'icône générique si le sexe n'est pas clair
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
              // Ajoutez d'autres informations pertinentes si tu les as dans ton modèle Citoyen
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Naviguer vers un écran d'édition de profil
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
                  // TODO: Naviguer vers un écran de changement de mot de passe
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
                  // Utilise le AuthProvider pour la déconnexion
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  // Redirige vers l'écran de connexion après déconnexion
                  // CORRECTION : Retire le 'const' ici
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()), // Retire 'const'
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

  // Widget utilitaire pour afficher une ligne d'information du profil
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
