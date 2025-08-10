// controllers/administrateurController.js
const { Administrateur, Commune } = require('../models');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'secret_key';

module.exports = {
  // Création d’un bourgmestre par un gouverneur
  async createAdministrateur(req, res) {
    try {
      const { username, password, communeId, nom, prenom, postnom, email } = req.body;

      // Validation des champs obligatoires
      if (!nom || !username || !password || !communeId) {
        return res.status(400).json({ message: "Champs obligatoires manquants." });
      }

      // Vérifier que la commune existe
      const commune = await Commune.findByPk(communeId);
      if (!commune) {
        return res.status(404).json({ message: "Commune introuvable." });
      }

      // Vérifier si la commune a déjà un bourgmestre (adminId dans Commune)
      if (commune.adminId) {
        return res.status(400).json({ message: "Cette commune a déjà un bourgmestre." });
      }

      // Vérifier si le username est déjà pris
      const existingUser = await Administrateur.findOne({ where: { username } });
      if (existingUser) {
        return res.status(400).json({ message: "Nom d'utilisateur déjà utilisé." });
      }

      // Hasher le mot de passe
      const hashedPassword = await bcrypt.hash(password, 10);

      // Créer l’admin (bourgmestre) sans communeId direct
      const admin = await Administrateur.create({
        nom,
        prenom,
        postnom,
        username,
        email,
        password: hashedPassword,
        role: 'admin' // rôle fixe bourgmestre
      });

      // Assigner le bourgmestre à la commune via adminId
      commune.adminId = admin.id;
      await commune.save();

      res.status(201).json({ message: "Bourgmestre ajouté avec succès", admin });
    } catch (err) {
      console.error("Erreur création administrateur :", err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Login administrateur (bourgmestre)
  async loginAdministrateur(req, res) {
    try {
      const { username, password } = req.body;

      const admin = await Administrateur.findOne({
        where: { username }
      });

      if (!admin) return res.status(404).json({ message: "Administrateur non trouvé" });

      const match = await bcrypt.compare(password, admin.password);
      if (!match) return res.status(401).json({ message: "Mot de passe incorrect" });

      // Pour récupérer provinceId, on cherche la commune liée (via adminId)
      const commune = await Commune.findOne({ where: { adminId: admin.id }, attributes: ['provinceId'] });

      const token = jwt.sign(
        {
          id: admin.id,
          role: admin.role,
          provinceId: commune ? commune.provinceId : null
        },
        JWT_SECRET,
        { expiresIn: '1d' }
      );

      res.status(200).json({ token });
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Liste de tous les bourgmestres
  async getAllAdministrateurs(req, res) {
    try {
      // Récupérer admins avec leur commune via Commune.adminId = admin.id
      const admins = await Administrateur.findAll({
        attributes: ['id', 'username', 'nom', 'prenom', 'postnom', 'role', 'email'],
        include: {
          model: Commune,
          as: 'communes', // via hasMany dans modèle admin
          attributes: ['id', 'nom', 'code', 'provinceId']
        }
      });

      // Construire nomComplet
      const adminsWithFullName = admins.map(admin => ({
        ...admin.get({ plain: true }),
        nomComplet: [admin.nom, admin.prenom, admin.postnom].filter(Boolean).join(' ')
      }));

      res.status(200).json(adminsWithFullName);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Récupérer les bourgmestres de la province d’un gouverneur
  async getAdminsOfMyProvince(req, res) {
    try {
      if (req.user.role !== 'admin_general') {
        return res.status(403).json({ message: "Accès interdit : rôle insuffisant" });
      }

      const { provinceId } = req.user;
      if (!provinceId) {
        return res.status(400).json({ message: "Province ID manquant dans le token" });
      }

      // Trouver toutes les communes dans la province
      // Puis filtrer les admins qui sont assignés à ces communes
      const communes = await Commune.findAll({
        where: { provinceId },
        attributes: ['adminId'],
        raw: true
      });

      const adminIds = communes.map(c => c.adminId).filter(id => id !== null);

      const admins = await Administrateur.findAll({
        where: { id: adminIds },
        attributes: ['id', 'username', 'nom', 'prenom', 'postnom', 'role']
      });

      const adminsWithFullName = admins.map(admin => ({
        ...admin.get({ plain: true }),
        nomComplet: [admin.nom, admin.prenom, admin.postnom].filter(Boolean).join(' ')
      }));

      res.status(200).json(adminsWithFullName);
    } catch (err) {
      console.error("Erreur getAdminsOfMyProvince:", err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Récupérer un bourgmestre par ID
  async getAdministrateurById(req, res) {
    try {
      const admin = await Administrateur.findByPk(req.params.id);
      if (!admin) return res.status(404).json({ message: "Non trouvé" });

      res.status(200).json(admin);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Mettre à jour un bourgmestre
  async updateAdministrateur(req, res) {
    try {
      const admin = await Administrateur.findByPk(req.params.id);
      if (!admin) return res.status(404).json({ message: "Non trouvé" });

      const { username, password, nom, prenom, postnom, email } = req.body;

      if (username) admin.username = username;
      if (password) admin.password = await bcrypt.hash(password, 10);
      if (nom) admin.nom = nom;
      if (prenom) admin.prenom = prenom;
      if (postnom) admin.postnom = postnom;
      if (email) admin.email = email;

      await admin.save();

      res.status(200).json(admin);
    } catch (err) {
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  },

  // Supprimer un bourgmestre et désassigner la commune liée
  async deleteAdministrateur(req, res) {
    try {
      const adminId = req.params.id;

      const admin = await Administrateur.findByPk(adminId);
      if (!admin) {
        return res.status(404).json({ message: "Bourgmestre non trouvé" });
      }

      // Trouver la commune supervisée par cet admin (adminId)
      const commune = await Commune.findOne({ where: { adminId } });
      if (commune) {
        commune.adminId = null; // désassigner le bourgmestre
        await commune.save();
      }

      // Supprimer le bourgmestre
      await admin.destroy();

      res.status(200).json({ message: "Bourgmestre supprimé avec succès" });
    } catch (err) {
      console.error("Erreur suppression administrateur :", err);
      res.status(500).json({ message: "Erreur serveur", error: err.message });
    }
  }
};