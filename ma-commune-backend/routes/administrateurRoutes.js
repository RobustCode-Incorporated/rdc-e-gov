const express = require('express');
const router = express.Router();
const adminController = require('../controllers/administrateurController');
const auth = require('../middleware/authMiddleware');

router.post('/', auth(['admin']), adminController.createAdministrateur);
router.get('/', auth(['admin']), adminController.getAllAdministrateurs);
router.get('/:id', auth(['admin']), adminController.getAdministrateurById);
router.put('/:id', auth(['admin']), adminController.updateAdministrateur);
// router.delete('/:id', auth(['admin']), adminController.deleteAdministrateur);

// Récupérer tous les admins de la province de l'admin_general connecté (plus sûr, sans paramètre en URL)
router.get('/province', auth(['admin_general']), adminController.getAdminsOfMyProvince);

module.exports = router;