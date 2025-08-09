const express = require('express');
const router = express.Router();
const controller = require('../controllers/communeController');
const auth = require('../middleware/authMiddleware');

// 🌐 Route publique
router.get('/', controller.getAllCommunes);

// ✅ Récupérer les communes de la province de l'admin général connecté
router.get('/province/:province', auth(['admin_general']), controller.getCommunesByProvince);

// 🔒 Routes protégées (réservées aux administrateurs de commune)
router.post('/', auth(['admin']), controller.createCommune);
router.get('/:id', auth(['admin']), controller.getCommuneById);
router.put('/:id', auth(['admin']), controller.updateCommune);

// ✅ Assigner ou modifier un administrateur à une commune (admin général uniquement)
router.put('/:communeId/assign-admin', auth(['admin_general']), controller.assignAdminToCommune);

module.exports = router;