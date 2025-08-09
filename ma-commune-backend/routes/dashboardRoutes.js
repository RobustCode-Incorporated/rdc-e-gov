const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');
const auth = require('../middleware/authMiddleware');

// Accès réservé aux administrateurs généraux
router.get('/admin-general', auth(['admin_general']), dashboardController.statsForAdminGeneral);

module.exports = router;