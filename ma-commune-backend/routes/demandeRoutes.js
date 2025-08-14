// routes/demandeRoutes.js
const express = require('express');
const router = express.Router();
const demandeController = require('../controllers/demandeController');
const auth = require('../middleware/authMiddleware');

// Route spécifique pour le citoyen connecté DOIT être définie en premier
router.get('/me', auth(['citoyen']), demandeController.getMyDemandes);

router.get('/validation', auth(['admin', 'admin_general']), demandeController.getDemandesToValidate);

// Les routes avec des paramètres généraux comme ':id' DOIVENT être définies après
router.get('/', auth(['agent', 'admin']), demandeController.getAllDemandes);
router.get('/:id', auth(['agent', 'admin']), demandeController.getDemandeById);
router.get('/:id', auth(['admin', 'agent']), demandeController.getOneDemande);
router.post('/', auth(['agent', 'citoyen' ]), demandeController.createDemande);
router.put('/:id', auth(['agent', 'admin']), demandeController.updateDemande);
router.delete('/:id', auth(['admin']), demandeController.deleteDemande);


module.exports = router;