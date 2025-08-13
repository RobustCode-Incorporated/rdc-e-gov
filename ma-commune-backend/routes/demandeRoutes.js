// routes/demandeRoutes.js
const express = require('express');
const router = express.Router();
const demandeController = require('../controllers/demandeController');
const auth = require('../middleware/authMiddleware');

router.get('/', auth(['agent', 'admin']), demandeController.getAllDemandes);
router.get('/:id', auth(['agent', 'admin']), demandeController.getDemandeById);
router.post('/', auth(['agent']), demandeController.createDemande);
router.put('/:id', auth(['agent', 'admin']), demandeController.updateDemande);
router.delete('/:id', auth(['admin']), demandeController.deleteDemande);

// Route spécifique pour le citoyen connecté
router.get('/me', auth(['citoyen']), demandeController.getMyDemandes);

module.exports = router;