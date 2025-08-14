// controllers/demandeController.js
const { Demande, Citoyen, Statut, Agent } = require('../models'); // Assurez-vous que Statut est bien importé

module.exports = {
  async getAllDemandes(req, res) {
    try {
      const demandes = await Demande.findAll({
        include: [{ model: Citoyen, as: 'citoyen' }, { model: Statut, as: 'statut' }, { model: Agent, as: 'agent' }],
        order: [['createdAt', 'DESC']]
      });
      res.json(demandes);
    } catch (error) {
      console.error('Erreur getAllDemandes:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
  },

  async getDemandeById(req, res) {
    try {
      const id = parseInt(req.params.id, 10);
      if (isNaN(id)) return res.status(400).json({ message: "ID invalide" });

      const demande = await Demande.findByPk(id, {
        include: [{ model: Citoyen, as: 'citoyen' }, { model: Statut, as: 'statut' }, { model: Agent, as: 'agent' }]
      });
      if (!demande) return res.status(404).json({ message: 'Demande non trouvée' });
      res.json(demande);
    } catch (error) {
      console.error('Erreur getDemandeById:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
  },

  async createDemande(req, res) {
    try {
      const demande = await Demande.create(req.body);
      res.status(201).json(demande);
    } catch (error) {
      console.error('Erreur createDemande:', error);
      res.status(400).json({ message: 'Erreur création demande', error: error.message });
    }
  },

  async updateDemande(req, res) {
    try {
      const demande = await Demande.findByPk(req.params.id);
      if (!demande) return res.status(404).json({ message: 'Demande non trouvée' });
      await demande.update(req.body);
      res.json(demande);
    } catch (error) {
      console.error('Erreur updateDemande:', error);
      res.status(400).json({ message: 'Erreur mise à jour', error: error.message });
    }
  },

  async deleteDemande(req, res) {
    try {
      const demande = await Demande.findByPk(req.params.id);
      if (!demande) return res.status(404).json({ message: 'Demande non trouvée' });
      await demande.destroy();
      res.status(204).send();
    } catch (error) {
      console.error('Erreur deleteDemande:', error);
      res.status(400).json({ message: 'Erreur suppression', error: error.message });
    }
  },

  // Nouvelle route : récupérer les demandes du citoyen connecté
  async getMyDemandes(req, res) {
    try {
      // Le middleware authMiddleware s'assure déjà du rôle, mais une vérification défensive est bien.
      if (!req.user || req.user.role !== 'citoyen') {
        return res.status(403).json({ message: 'Accès interdit : rôle insuffisant' });
      }

      const demandes = await Demande.findAll({
        where: { citoyenId: req.user.id },
        include: [{ model: Statut, as: 'statut' }],
        order: [['createdAt', 'DESC']]
      });

      res.json(demandes);
    } catch (error) {
      console.error('Erreur getMyDemandes:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
  },

  // NOUVELLE FONCTION : Pour récupérer tous les statuts
  async getAllStatuts(req, res) {
    try {
      // S'assure que le modèle Statut est bien importé en haut du fichier
      const statuts = await Statut.findAll();
      return res.status(200).json(statuts);
    } catch (error) {
      console.error('Erreur getAllStatuts:', error);
      return res.status(500).json({ message: 'Erreur serveur lors de la récupération des statuts', error: error.message });
    }
  }
};