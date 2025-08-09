const { Agent } = require('../models');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'secret_key';

module.exports = {
  async createAgent(req, res) {
    try {
      const { username, password, communeId } = req.body;

      const existing = await Agent.findOne({ where: { username } });
      if (existing) return res.status(400).json({ message: "Nom d'utilisateur déjà utilisé" });

      const hashedPassword = await bcrypt.hash(password, 10);

      const agent = await Agent.create({
        username,
        password: hashedPassword,
        communeId
      });

      res.status(201).json(agent);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  async loginAgent(req, res) {
    try {
      const { username, password } = req.body;

      const agent = await Agent.findOne({ where: { username } });
      if (!agent) return res.status(404).json({ message: "Agent non trouvé" });

      const match = await bcrypt.compare(password, agent.password);
      if (!match) return res.status(401).json({ message: "Mot de passe incorrect" });

      const token = jwt.sign({ id: agent.id, role: 'agent' }, JWT_SECRET, { expiresIn: '1d' });

      res.status(200).json({ token });
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  async getAllAgents(req, res) {
    try {
      const agents = await Agent.findAll();
      res.status(200).json(agents);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  async getAgentById(req, res) {
    try {
      const agent = await Agent.findByPk(req.params.id);
      if (!agent) return res.status(404).json({ message: "Agent non trouvé" });

      res.status(200).json(agent);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  async updateAgent(req, res) {
    try {
      const agent = await Agent.findByPk(req.params.id);
      if (!agent) return res.status(404).json({ message: "Non trouvé" });

      const { username, password, communeId } = req.body;
      if (username) agent.username = username;
      if (password) agent.password = await bcrypt.hash(password, 10);
      if (communeId) agent.communeId = communeId;

      await agent.save();

      res.status(200).json(agent);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  }
};