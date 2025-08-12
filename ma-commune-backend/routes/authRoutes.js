const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController'); // Assurez-vous d'avoir ce contrôleur

// Route pour la connexion
router.post('/login', authController.login);

// Route pour l'inscription (si elle est gérée par authRoutes, sinon elle est dans citoyenRoutes)
// Si votre inscription est déjà dans citoyenRoutes, vous n'avez pas besoin de cette ligne ici.
// router.post('/register', authController.register);

module.exports = router;
