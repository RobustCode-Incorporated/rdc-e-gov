const { AdministrateurGeneral } = require('../models');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// ✅ Assure une clé cohérente dans tous les fichiers
const JWT_SECRET = process.env.JWT_SECRET || 'ma_cle_super_secrete';

module.exports = {
  // ✅ Création d’un administrateur général
  async createAdminGeneral(req, res) {
    try {
      const { nomComplet, username, password, email, provinceId } = req.body;

      const existingAdminGeneral = await AdministrateurGeneral.findOne({ where: { provinceId } });
      if (existingAdminGeneral) {
        return res.status(400).json({ message: "Un administrateur général existe déjà pour cette province." });
      }

      const existingUsername = await AdministrateurGeneral.findOne({ where: { username } });
      if (existingUsername) {
        return res.status(400).json({ message: "Nom d'utilisateur déjà utilisé." });
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      const adminGeneral = await AdministrateurGeneral.create({
        nomComplet,
        username,
        password: hashedPassword,
        email,
        provinceId,
        role: 'admin_general',
      });

      res.status(201).json({ message: "Administrateur général créé avec succès.", adminGeneral });
    } catch (err) {
      console.error('Erreur création Admin Général:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // ✅ Connexion admin général (login)
  async loginAdminGeneral(req, res) {
    try {
      const { username, password } = req.body;

      const admin = await AdministrateurGeneral.findOne({ where: { username } });
      if (!admin) return res.status(404).json({ message: "Administrateur général non trouvé" });

      const match = await bcrypt.compare(password, admin.password);
      if (!match) return res.status(401).json({ message: "Mot de passe incorrect" });

      // ✅ Génération du token avec provinceId (pour sécuriser les accès)
      const token = jwt.sign(
        {
          id: admin.id,
          role: 'admin_general',
          provinceId: admin.provinceId
        },
        JWT_SECRET,
        { expiresIn: '1d' }
      );

      res.status(200).json({ token });
    } catch (err) {
      console.error('Erreur login Admin Général:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // ✅ Liste des admins généraux
  async getAllAdminGenerals(req, res) {
    try {
      const adminGenerals = await AdministrateurGeneral.findAll();
      res.status(200).json(adminGenerals);
    } catch (err) {
      console.error('Erreur récupération admins généraux:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // ✅ Récupérer un admin général par ID
  async getAdminGeneralById(req, res) {
    try {
      const adminGeneral = await AdministrateurGeneral.findByPk(req.params.id);
      if (!adminGeneral) return res.status(404).json({ message: "Administrateur général non trouvé" });

      res.status(200).json(adminGeneral);
    } catch (err) {
      console.error('Erreur récupération admin général par ID:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // ✅ Mise à jour
  async updateAdminGeneral(req, res) {
    try {
      const adminGeneral = await AdministrateurGeneral.findByPk(req.params.id);
      if (!adminGeneral) return res.status(404).json({ message: "Administrateur général non trouvé" });

      const { nomComplet, username, password, email, provinceId } = req.body;

      if (username && username !== adminGeneral.username) {
        const existingUsername = await AdministrateurGeneral.findOne({ where: { username } });
        if (existingUsername) {
          return res.status(400).json({ message: "Nom d'utilisateur déjà utilisé." });
        }
        adminGeneral.username = username;
      }

      if (nomComplet) adminGeneral.nomComplet = nomComplet;
      if (email) adminGeneral.email = email;
      if (provinceId) adminGeneral.provinceId = provinceId;
      if (password) adminGeneral.password = await bcrypt.hash(password, 10);

      await adminGeneral.save();

      res.status(200).json({ message: "Administrateur général mis à jour", adminGeneral });
    } catch (err) {
      console.error('Erreur mise à jour Admin Général:', err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  }
};