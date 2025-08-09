const express = require('express');
const router = express.Router();
const demandeController = require('../controllers/demandeController');
const auth = require('../middleware/authMiddleware');

router.get('/', auth(['agent', 'admin']), demandeController.getAllDemandes);
router.get('/:id', auth(['agent', 'admin']), demandeController.getDemandeById);
router.post('/', auth(['agent']), demandeController.createDemande);
router.put('/:id', auth(['agent', 'admin']), demandeController.updateDemande);
router.delete('/:id', auth(['admin']), demandeController.deleteDemande);

module.exports = router;