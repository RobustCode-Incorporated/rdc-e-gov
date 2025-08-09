const express = require('express');
const router = express.Router();
const statutController = require('../controllers/statutController');
const auth = require('../middleware/authMiddleware');

// 🔒 Lire tous les statuts (accès : admin_general, admin, agent)
router.get('/', auth(['admin_general', 'admin', 'agent']), statutController.getAllStatuts);

// 🔒 Créer un nouveau statut (accès : admin uniquement)
router.post('/', auth(['admin']), statutController.createStatut);

// 🔒 Récupérer les statistiques du dashboard (accès : admin_general uniquement)
router.get('/dashboardAdmin', auth(['admin_general']), statutController.getDashboardStats);

module.exports = router;