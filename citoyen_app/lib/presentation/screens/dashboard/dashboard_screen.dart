import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citoyen_app/config/app_theme.dart';
import 'package:citoyen_app/data/providers/auth_provider.dart';
import 'package:citoyen_app/data/providers/demande_provider.dart';
import 'package:citoyen_app/presentation/screens/demandes/demandes_list_screen.dart';
import 'package:citoyen_app/presentation/screens/my_documents/my_documents_screen.dart';
import 'package:citoyen_app/presentation/screens/profile/profile_screen.dart';
import 'package:citoyen_app/presentation/screens/demandes/form_acte_naissance_screen.dart';
import 'package:citoyen_app/utils/app_router.dart';
import 'package:citoyen_app/data/models/statut_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    _DashboardHome(),
    DemandesListScreen(),
    MyDocumentsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DemandeProvider>(context, listen: false).fetchMyDemandes();
      Provider.of<DemandeProvider>(context, listen: false).fetchStatuts();
      Provider.of<DemandeProvider>(context, listen: false).fetchValidatedDocuments();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final citoyen = authProvider.currentCitoyen;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Accueil'
              : _selectedIndex == 1
                  ? 'Mes Demandes'
                  : _selectedIndex == 2
                      ? 'Mes Documents'
                      : 'Mon Profil',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              AppRouter.navigateToLogin(context);
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Mes Demandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            label: 'Mes Docs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mediumGray,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  String getStatutName(List<Statut> statuts, int statutId) {
    return statuts.firstWhere((s) => s.id == statutId, orElse: () => Statut(id: statutId, nom: 'Inconnu')).nom;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final demandeProvider = Provider.of<DemandeProvider>(context);
    final citoyen = authProvider.currentCitoyen;

    final Map<int, int> statusCounts = {};
    for (var demande in demandeProvider.demandes) {
      statusCounts[demande.statutId] = (statusCounts[demande.statutId] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour ${citoyen?.prenom ?? 'Citoyen'} !',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Statut de vos demandes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          demandeProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
              : demandeProvider.statuts.isEmpty
                  ? const Center(child: Text('Aucun statut disponible.'))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        // Correction : Augmentez la hauteur des cartes en diminuant le childAspectRatio
                        childAspectRatio: 1.2,
                      ),
                      itemCount: demandeProvider.statuts.length,
                      itemBuilder: (context, index) {
                        final statut = demandeProvider.statuts[index];
                        final count = statusCounts[statut.id] ?? 0;
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          // MODIFICATION : onTap est maintenant null pour rendre le bloc non cliquable
                          child: InkWell( 
                            onTap: null, // Rendre ce InkWell non cliquable
                            borderRadius: BorderRadius.circular(12.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      statut.nom.toUpperCase(),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    '$count',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: AppColors.darkText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'demande(s)',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.brownText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          const SizedBox(height: 32.0),
          Text(
            'Faire une nouvelle demande',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              _buildDocumentRequestCard(
                context,
                'Acte de Naissance',
                Icons.baby_changing_station,
                () => AppRouter.navigateToFormActeNaissance(context),
              ),
              _buildDocumentRequestCard(
                context,
                'Carte d\'Identité',
                Icons.badge,
                () => AppRouter.navigateToFormCarteIdentite(context),
              ),
              _buildDocumentRequestCard(
                context,
                'Acte de Mariage',
                Icons.favorite,
                () => AppRouter.navigateToFormActeMariage(context),
              ),
              _buildDocumentRequestCard(
                context,
                'Acte de Résidence',
                Icons.home,
                () => AppRouter.navigateToFormActeResidence(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRequestCard(
      BuildContext context, String title, IconData icon, VoidCallback onTapAction) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTapAction,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.primaryBlue),
            const SizedBox(height: 8.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
