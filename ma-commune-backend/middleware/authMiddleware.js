// middleware/authMiddleware.js
const jwt = require('jsonwebtoken');
const { Citoyen, Administrateur, Agent, AdministrateurGeneral } = require('../models');
const { jwtSecret } = require('../config'); // clé secrète centralisée

// Liste des routes publiques à ignorer (méthode et chemin RegExp)
// IMPORTANT : ne pas inclure '/api' dans les chemins car middleware est appliqué sur '/api'
const publicPaths = [
  { method: 'GET', path: /^\/provinces\/?$/ },
  { method: 'GET', path: /^\/communes\/public\/province\/\d+\/?$/ },
  { method: 'POST', path: /^\/auth\/login\/?$/ },
  { method: 'POST', path: /^\/citoyens\/register\/?$/ },
  // Ajoute d'autres routes publiques ici si besoin
];

function isPublicRoute(req) {
  // On ne considère que la partie path sans query params
  const path = req.path;
  return publicPaths.some(route =>
    route.method === req.method && route.path.test(path)
  );
}

const authMiddleware = (roles = []) => {
  return async (req, res, next) => {
    // Ignore l’authentification pour les routes publiques
    if (isPublicRoute(req)) {
      return next();
    }

    const authHeader = req.headers['authorization'];
    const token = authHeader?.split(' ')[1];

    if (!token) {
      return res.status(401).json({ message: 'Token manquant' });
    }

    try {
      const payload = jwt.verify(token, jwtSecret);

      let user = null;

      switch (payload.role) {
        case 'citoyen':
          user = await Citoyen.findByPk(payload.id);
          break;
        case 'admin':
          user = await Administrateur.findByPk(payload.id);
          break;
        case 'agent':
          user = await Agent.findByPk(payload.id);
          break;
        case 'admin_general':
          user = await AdministrateurGeneral.findByPk(payload.id);
          break;
        default:
          return res.status(401).json({ message: 'Rôle invalide dans le token' });
      }

      if (!user) {
        return res.status(401).json({ message: 'Utilisateur invalide ou introuvable' });
      }

      if (roles.length && !roles.includes(payload.role)) {
        return res.status(403).json({ message: 'Accès interdit : rôle insuffisant' });
      }

      req.user = {
        id: payload.id,
        role: payload.role,
        provinceId: payload.provinceId || null,
        communeId: payload.communeId || null,
        typeDemande: payload.typeDemande || null,
      };
      console.log('Utilisateur attaché à la requête:', req.user);
      next();
    } catch (err) {
      console.error('Erreur vérification JWT:', err);
      return res.status(403).json({ message: 'Token invalide' });
    }
  };
};

module.exports = authMiddleware;