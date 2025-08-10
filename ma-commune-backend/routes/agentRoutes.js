// routes/agentRoutes.js
const express = require('express');
const router = express.Router();
const controller = require('../controllers/agentController');
const auth = require('../middleware/authMiddleware');

// Création d’un agent (réservé au bourgmestre connecté)
router.post('/', auth(['admin']), controller.createAgent);

// Liste des agents de la commune du bourgmestre
router.get('/', auth(['admin']), controller.getAgentsOfMyCommune);

// Voir un agent par ID
router.get('/:id', auth(['admin']), controller.getAgentById);

// Modifier un agent
router.put('/:id', auth(['admin']), controller.updateAgent);

// Supprimer un agent
router.delete('/:id', auth(['admin']), controller.deleteAgent);

module.exports = router;