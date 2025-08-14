// routes/statutRoutes.js
const express = require('express');
const router = express.Router();
const statutController = require('../controllers/statutController');
const demandeController = require('../controllers/demandeController');
const auth = require('../middleware/authMiddleware');

// Nouvelle route pour que les citoyens puissent voir les statuts
router.get('/', auth(['citoyen']), demandeController.getAllStatuts);

// Routes protégées pour admin, agent
router.get('/', auth(['admin_general', 'admin', 'agent']), statutController.getAllStatuts);
router.post('/', auth(['admin']), statutController.createStatut);
router.get('/dashboardAdmin', auth(['admin_general']), statutController.getDashboardStats);

// Route publique pour les citoyens
router.get('/public', statutController.getAllStatutsPublic);

module.exports = router;