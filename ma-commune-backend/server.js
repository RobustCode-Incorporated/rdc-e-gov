// server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./models');

const communeRoutes = require('./routes/communeRoutes');
const agentRoutes = require('./routes/agentRoutes');
const administrateurRoutes = require('./routes/administrateurRoutes');
const administrateurGeneralRoutes = require('./routes/administrateurGeneralRoutes');
const citoyenRoutes = require('./routes/citoyenRoutes');
const demandeRoutes = require('./routes/demandeRoutes');
const statutRoutes = require('./routes/statutRoutes');
const provinceRoutes = require('./routes/provinceRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const authRoutes = require('./routes/authRoutes');

const authMiddleware = require('./middleware/authMiddleware');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'API Ma Commune fonctionne ✅' });
});

// ✅ Routes publiques (pas d'auth)
app.use('/api/auth', authRoutes);
app.use('/api/provinces', provinceRoutes);
app.use('/api/communes/public', communeRoutes); // partie publique

// ✅ Middleware global pour toutes les routes suivantes
app.use('/api', authMiddleware());

// ✅ Routes protégées
app.use('/api/citoyens', citoyenRoutes);
app.use('/api/communes', communeRoutes); // partie protégée
app.use('/api/administrateurs', administrateurRoutes);
app.use('/api/administrateurs-generaux', administrateurGeneralRoutes);
app.use('/api/agents', agentRoutes);
app.use('/api/demandes', demandeRoutes);
app.use('/api/statuts', statutRoutes);
app.use('/api/dashboard', dashboardRoutes);

// DB + lancement serveur
db.sequelize.sync({ alter: true })
  .then(() => {
    console.log('✅ Base de données synchronisée');
    return db.sequelize.authenticate();
  })
  .then(() => {
    console.log('✅ Connexion à la base réussie');
    const PORT = process.env.PORT || 4000;
    app.listen(PORT, () => console.log(`🚀 Serveur lancé sur le port ${PORT}`));
  })
  .catch(err => {
    console.error('❌ Erreur DB:', err);
  });