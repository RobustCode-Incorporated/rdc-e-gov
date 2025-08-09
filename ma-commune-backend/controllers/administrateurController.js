const { Administrateur, Commune } = require('../models');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'secret_key';

module.exports = {
  // Créer un administrateur (inscription)
  async createAdministrateur(req, res) {
    try {
      const { username, password, communeId } = req.body;

      const existing = await Administrateur.findOne({ where: { username } });
      if (existing) return res.status(400).json({ message: "Nom d'utilisateur déjà utilisé" });

      const hashedPassword = await bcrypt.hash(password, 10);

      const admin = await Administrateur.create({
        username,
        password: hashedPassword,
        communeId
      });

      res.status(201).json(admin);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Login (si besoin)
  async loginAdministrateur(req, res) {
    try {
      const { username, password } = req.body;

      const admin = await Administrateur.findOne({ where: { username } });
      if (!admin) return res.status(404).json({ message: "Administrateur non trouvé" });

      const match = await bcrypt.compare(password, admin.password);
      if (!match) return res.status(401).json({ message: "Mot de passe incorrect" });

      const token = jwt.sign({ id: admin.id, role: 'admin', provinceId: admin.communeId /* ou autre */ }, JWT_SECRET, { expiresIn: '1d' });

      res.status(200).json({ token });
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Liste des administrateurs
  async getAllAdministrateurs(req, res) {
    try {
      const admins = await Administrateur.findAll();
      res.status(200).json(admins);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Récupérer les admins de la province du token (admin_general)
  async getAdminsOfMyProvince(req, res) {
    try {
      const { provinceId } = req.user;
      if (!provinceId) return res.status(400).json({ message: "Province ID manquant dans le token" });

      const admins = await Administrateur.findAll({
        include: {
          model: Commune,
          as: 'commune',
          where: { provinceId },
          attributes: ['id', 'nom']
        },
        attributes: ['id', 'username', 'nom', 'prenom', 'postnom']
      });

      res.status(200).json(admins);
    } catch (err) {
      console.error("Erreur getAdminsOfMyProvince:", err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Récupérer un administrateur par ID
  async getAdministrateurById(req, res) {
    try {
      const admin = await Administrateur.findByPk(req.params.id);
      if (!admin) return res.status(404).json({ message: "Non trouvé" });

      res.status(200).json(admin);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Mettre à jour un administrateur
  async updateAdministrateur(req, res) {
    try {
      const admin = await Administrateur.findByPk(req.params.id);
      if (!admin) return res.status(404).json({ message: "Non trouvé" });

      const { username, password, communeId } = req.body;
      if (username) admin.username = username;
      if (password) admin.password = await bcrypt.hash(password, 10);
      if (communeId) admin.communeId = communeId;

      await admin.save();

      res.status(200).json(admin);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  }
};