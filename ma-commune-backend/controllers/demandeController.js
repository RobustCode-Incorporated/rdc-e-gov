// controllers/demandeController.js
const { Demande, Citoyen, Statut, Agent } = require('../models');

module.exports = {
  // Récupérer toutes les demandes avec les relations
  async getAllDemandes(req, res) {
    try {
      const demandes = await Demande.findAll({
        include: [
          { model: Citoyen, as: 'citoyen' },
          { model: Statut, as: 'statut' },
          { model: Agent, as: 'agent' } // Assure-toi que l'association existe avec l'alias 'agent'
        ],
        order: [['createdAt', 'DESC']]
      });
      res.json(demandes);
    } catch (error) {
      console.error('Erreur getAllDemandes:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
  },

  // Récupérer une demande par son ID
  async getDemandeById(req, res) {
    try {
      const demande = await Demande.findByPk(req.params.id, {
        include: [
          { model: Citoyen, as: 'citoyen' },
          { model: Statut, as: 'statut' },
          { model: Agent, as: 'agent' }
        ]
      });
      if (!demande) {
        return res.status(404).json({ message: 'Demande non trouvée' });
      }
      res.json(demande);
    } catch (error) {
      console.error('Erreur getDemandeById:', error);
      res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
  },

  // Créer une nouvelle demande
  async createDemande(req, res) {
    try {
      const demande = await Demande.create(req.body);
      res.status(201).json(demande);
    } catch (error) {
      console.error('Erreur createDemande:', error);
      res.status(400).json({ message: 'Erreur création demande', error: error.message });
    }
  },

  // Mettre à jour une demande existante
  async updateDemande(req, res) {
    try {
      const demande = await Demande.findByPk(req.params.id);
      if (!demande) {
        return res.status(404).json({ message: 'Demande non trouvée' });
      }

      await demande.update(req.body);
      res.json(demande);
    } catch (error) {
      console.error('Erreur updateDemande:', error);
      res.status(400).json({ message: 'Erreur mise à jour', error: error.message });
    }
  },

  // Supprimer une demande
  async deleteDemande(req, res) {
    try {
      const demande = await Demande.findByPk(req.params.id);
      if (!demande) {
        return res.status(404).json({ message: 'Demande non trouvée' });
      }

      await demande.destroy();
      res.status(204).send();
    } catch (error) {
      console.error('Erreur deleteDemande:', error);
      res.status(400).json({ message: 'Erreur suppression', error: error.message });
    }
  }
};