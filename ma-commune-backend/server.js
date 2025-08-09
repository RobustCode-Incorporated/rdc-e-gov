require('dotenv').config();
const express = require('express');
const cors = require('cors');

const db = require('./models'); // Import de Sequelize et de tous les modèles

// Importation des routes
const communeRoutes = require('./routes/communeRoutes');
const agentRoutes = require('./routes/agentRoutes');
const administrateurRoutes = require('./routes/administrateurRoutes');
const administrateurGeneralRoutes = require('./routes/administrateurGeneralRoutes');
const citoyenRoutes = require('./routes/citoyenRoutes');
const demandeRoutes = require('./routes/demandeRoutes');
const statutRoutes = require('./routes/statutRoutes');
const provinceRoutes = require('./routes/provinceRoutes');

const app = express();

// Middlewares globaux
app.use(cors());
app.use(express.json());

// Route de test
app.get('/', (req, res) => {
  res.json({ message: 'API Ma Commune fonctionne ✅' });
});

// Déclaration des routes REST
app.use('/api/administrateurs', administrateurRoutes);
app.use('/api/administrateurs-generaux', administrateurGeneralRoutes);
app.use('/api/communes', communeRoutes);
app.use('/api/agents', agentRoutes);
app.use('/api/citoyens', citoyenRoutes);
app.use('/api/demandes', demandeRoutes);
app.use('/api/statuts', statutRoutes);
app.use('/api/provinces', provinceRoutes);

// ✅ Nouvelle route pour dashboard admin général
app.use('/api/dashboard', require('./routes/dashboardRoutes'));
app.use('/api/administrateurs', require('./routes/administrateurRoutes'));


// Connexion à la base de données + Synchronisation des modèles
db.sequelize.sync({ alter: true }) // 'alter: true' ajuste tables sans tout supprimer
  .then(() => {
    console.log('✅ Base de données synchronisée');
    return db.sequelize.authenticate();
  })
  .then(() => {
    console.log('✅ Connexion à la base réussie');
    // Démarrage du serveur **après** la synchro et la connexion
    const PORT = process.env.PORT || 4000;
    app.listen(PORT, () => console.log(`🚀 Serveur lancé sur le port ${PORT}`));
  })
  .catch(err => {
    console.error('❌ Erreur lors de la synchronisation ou connexion:', err);
  });