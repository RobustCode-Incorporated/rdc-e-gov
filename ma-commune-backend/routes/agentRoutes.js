const express = require('express');
const router = express.Router();
const controller = require('../controllers/agentController');
const auth = require('../middleware/authMiddleware');

router.post('/', auth(['admin']), controller.createAgent);
router.get('/', auth(['admin']), controller.getAllAgents);
router.get('/:id', auth(['admin']), controller.getAgentById);
router.put('/:id', auth(['admin']), controller.updateAgent);
//router.delete('/:id', auth(['admin']), controller.deleteAgent);

module.exports = router;