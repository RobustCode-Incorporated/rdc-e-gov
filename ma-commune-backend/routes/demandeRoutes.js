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

// NOTE: Vous aviez deux routes GET /:id. J'ai conservé getDemandeById et retiré getOneDemande pour éviter la duplication.
// router.get('/:id', auth(['admin', 'agent']), demandeController.getOneDemande); // REDONDANT, RETIRÉ

router.post('/', auth(['agent', 'citoyen' ]), demandeController.createDemande);
router.put('/:id', auth(['agent', 'admin']), demandeController.updateDemande);
router.delete('/:id', auth(['admin']), demandeController.deleteDemande);

// NOUVELLE ROUTE POUR LA GÉNÉRATION DE DOCUMENT
router.put('/:id/generate-document', auth(['agent', 'admin']), demandeController.generateDocument);

// NOUVELLE ROUTE POUR LA VALIDATION FINALE DU DOCUMENT PAR L'ADMIN
router.put('/:id/validate-document', auth(['admin']), demandeController.validateDocument);

// NOUVELLE ROUTE POUR LE TÉLÉCHARGEMENT DU DOCUMENT (pour plus tard, si nécessaire)
// router.get('/:id/download', auth(['citoyen', 'agent', 'admin']), demandeController.downloadDocument);


module.exports = router;