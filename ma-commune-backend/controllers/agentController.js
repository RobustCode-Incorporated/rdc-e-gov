// controllers/agentController.js
const { Agent, Commune } = require('../models');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'ma_cle_super_secrete';

module.exports = {
  // Créer un agent (uniquement par bourgmestre - role 'admin')
  async createAgent(req, res) {
    try {
      const { nom, prenom, postnom, username, password, typeDemande } = req.body;

      // Utilise req.user passé par authMiddleware pour récupérer l'id admin (bourgmestre)
      const adminId = req.user?.id;
      if (!adminId || req.user.role !== 'admin') {
        return res.status(403).json({ message: "Accès refusé" });
      }

      // Trouve la commune gérée par ce bourgmestre
      const commune = await Commune.findOne({ where: { adminId } });
      if (!commune) {
        return res.status(400).json({ message: "Impossible de trouver votre commune" });
      }

      // Vérifie que le username est unique
      const existing = await Agent.findOne({ where: { username } });
      if (existing) return res.status(400).json({ message: "Nom d'utilisateur déjà utilisé" });

      const hashedPassword = await bcrypt.hash(password, 10);

      const agent = await Agent.create({
        nom,
        prenom,
        postnom,
        username,
        password: hashedPassword,
        communeId: commune.id,
        typeDemande
      });

      res.status(201).json(agent);
    } catch (err) {
      console.error('Erreur createAgent:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Connexion agent
  async loginAgent(req, res) {
    try {
      const { username, password } = req.body;

      const agent = await Agent.findOne({ where: { username } });
      if (!agent) return res.status(404).json({ message: "Agent non trouvé" });

      const match = await bcrypt.compare(password, agent.password);
      if (!match) return res.status(401).json({ message: "Mot de passe incorrect" });

      const token = jwt.sign(
        { id: agent.id, role: 'agent', communeId: agent.communeId, typeDemande: agent.typeDemande },
        JWT_SECRET,
        { expiresIn: '1d' }
      );

      res.status(200).json({ token });
    } catch (err) {
      console.error('Erreur loginAgent:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Récupérer tous les agents de la commune du bourgmestre connecté
  async getAgentsOfMyCommune(req, res) {
    try {
      const adminId = req.user?.id;
      if (!adminId || req.user.role !== 'admin') {
        return res.status(403).json({ message: "Accès refusé" });
      }

      const commune = await Commune.findOne({ where: { adminId } });
      if (!commune) {
        return res.status(400).json({ message: "Impossible de trouver votre commune" });
      }

      const agents = await Agent.findAll({
        where: { communeId: commune.id },
        include: [{ model: Commune, as: 'commune' }]
      });

      res.status(200).json(agents);
    } catch (err) {
      console.error('Erreur getAgentsOfMyCommune:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Récupérer un agent par ID
  async getAgentById(req, res) {
    try {
      const agent = await Agent.findByPk(req.params.id, {
        include: [{ model: Commune, as: 'commune' }]
      });
      if (!agent) return res.status(404).json({ message: "Agent non trouvé" });

      res.status(200).json(agent);
    } catch (err) {
      console.error('Erreur getAgentById:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Mettre à jour un agent
  async updateAgent(req, res) {
    try {
      const { nom, prenom, postnom, username, password, typeDemande } = req.body;

      const agent = await Agent.findByPk(req.params.id);
      if (!agent) return res.status(404).json({ message: "Agent non trouvé" });

      if (nom) agent.nom = nom;
      if (prenom) agent.prenom = prenom;
      if (postnom) agent.postnom = postnom;
      if (username) agent.username = username;
      if (password) agent.password = await bcrypt.hash(password, 10);
      if (typeDemande) agent.typeDemande = typeDemande;

      await agent.save();

      res.status(200).json(agent);
    } catch (err) {
      console.error('Erreur updateAgent:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Supprimer un agent
  async deleteAgent(req, res) {
    try {
      const agent = await Agent.findByPk(req.params.id);
      if (!agent) return res.status(404).json({ message: "Agent non trouvé" });

      await agent.destroy();
      res.status(200).json({ message: "Agent supprimé avec succès" });
    } catch (err) {
      console.error('Erreur deleteAgent:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  }
};