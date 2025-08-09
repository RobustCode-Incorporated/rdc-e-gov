const { Commune, Administrateur } = require('../models');

module.exports = {
  // Récupérer toutes les communes
  async getAllCommunes(req, res) {
    try {
      const communes = await Commune.findAll({
        include: [
          { 
            model: Administrateur, 
            as: 'administrateur', 
            attributes: ['id', 'username', 'nom', 'prenom', 'postnom'] 
          }
        ],
        order: [['nom', 'ASC']]
      });

      // Construire nomComplet pour chaque admin
      communes.forEach(commune => {
        if (commune.administrateur) {
          const a = commune.administrateur;
          a.nomComplet = [a.nom, a.prenom, a.postnom].filter(Boolean).join(' ');
        }
      });

      res.status(200).json(communes);
    } catch (err) {
      console.error('Erreur getAllCommunes:', err);
      res.status(500).json({ message: 'Erreur serveur', error: err.message });
    }
  },

  // Créer une nouvelle commune
  async createCommune(req, res) {
    try {
      const { nom, code, provinceId, adminId } = req.body;

      if (!nom || !provinceId) {
        return res.status(400).json({ message: 'Nom et provinceId sont requis' });
      }

      const newCommune = await Commune.create({ nom, code, provinceId, adminId: adminId || null });
      res.status(201).json(newCommune);
    } catch (err) {
      console.error('Erreur createCommune:', err);
      res.status(500).json({ message: 'Erreur serveur', error: err.message });
    }
  },

  // Récupérer une commune par son ID
  async getCommuneById(req, res) {
    try {
      const commune = await Commune.findByPk(req.params.id, {
        include: [
          { 
            model: Administrateur, 
            as: 'administrateur', 
            attributes: ['id', 'username', 'nom', 'prenom', 'postnom'] 
          }
        ]
      });
      if (!commune) return res.status(404).json({ message: 'Commune non trouvée' });

      if (commune.administrateur) {
        const a = commune.administrateur;
        a.nomComplet = [a.nom, a.prenom, a.postnom].filter(Boolean).join(' ');
      }

      res.status(200).json(commune);
    } catch (err) {
      console.error('Erreur getCommuneById:', err);
      res.status(500).json({ message: 'Erreur serveur', error: err.message });
    }
  },

  // Mettre à jour une commune
  async updateCommune(req, res) {
    try {
      const commune = await Commune.findByPk(req.params.id);
      if (!commune) return res.status(404).json({ message: 'Commune non trouvée' });

      const { nom, code, provinceId, adminId } = req.body;

      if (nom !== undefined) commune.nom = nom;
      if (code !== undefined) commune.code = code;
      if (provinceId !== undefined) commune.provinceId = provinceId;
      if (adminId !== undefined) commune.adminId = adminId;

      await commune.save();
      res.status(200).json(commune);
    } catch (err) {
      console.error('Erreur updateCommune:', err);
      res.status(500).json({ message: 'Erreur serveur', error: err.message });
    }
  },

  // Récupérer les communes d'une province (par nom ou id)
  async getCommunesByProvince(req, res) {
    try {
      const provinceParam = req.params.province;

      const whereClause = /^\d+$/.test(provinceParam)
        ? { provinceId: parseInt(provinceParam, 10) }
        : { province: provinceParam }; // fallback, si colonne province string existante

      const communes = await Commune.findAll({
        where: whereClause,
        include: [
          { 
            model: Administrateur, 
            as: 'administrateur', 
            attributes: ['id', 'username', 'nom', 'prenom', 'postnom'] 
          }
        ],
        order: [['nom', 'ASC']]
      });

      communes.forEach(commune => {
        if (commune.administrateur) {
          const a = commune.administrateur;
          a.nomComplet = [a.nom, a.prenom, a.postnom].filter(Boolean).join(' ');
        }
      });

      res.status(200).json(communes);
    } catch (err) {
      console.error('Erreur getCommunesByProvince:', err);
      res.status(500).json({ message: 'Erreur serveur', error: err.message });
    }
  },

  // Assigner ou modifier l’administrateur d’une commune
  async assignAdminToCommune(req, res) {
    try {
      const { communeId } = req.params;
      const { adminId } = req.body;

      const commune = await Commune.findByPk(communeId);
      if (!commune) return res.status(404).json({ message: 'Commune non trouvée' });

      commune.adminId = adminId || null;
      await commune.save();

      res.status(200).json({ message: 'Administrateur assigné', commune });
    } catch (err) {
      console.error('Erreur assignAdminToCommune:', err);
      res.status(500).json({ message: 'Erreur serveur', error: err.message });
    }
  }
};