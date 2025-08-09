const express = require('express');
const router = express.Router();
const citoyenController = require('../controllers/citoyenController');
const auth = require('../middleware/authMiddleware');

// Accès aux agents ou admins
router.get('/', auth(['agent', 'admin']), citoyenController.getAllCitoyens);
router.get('/:id', auth(['agent', 'admin']), citoyenController.getCitoyenById);
router.post('/', auth(['agent', 'admin']), citoyenController.createCitoyen);
router.put('/:id', auth(['agent', 'admin']), citoyenController.updateCitoyen);
router.delete('/:id', auth(['admin']), citoyenController.deleteCitoyen); // suppression réservée à l’admin

module.exports = router;