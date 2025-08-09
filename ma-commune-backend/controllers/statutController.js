const { Statut, Commune, Administrateur, Agent } = require('../models');

// 🟢 Renvoyer tous les statuts
const getAllStatuts = async (req, res) => {
  try {
    const statuts = await Statut.findAll();
    res.json(statuts);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error });
  }
};

// 🟢 Créer un nouveau statut
const createStatut = async (req, res) => {
  try {
    const newStatut = await Statut.create(req.body);
    res.status(201).json(newStatut);
  } catch (error) {
    res.status(400).json({ message: 'Erreur création', error });
  }
};

// ✅ Statistiques globales pour dashboard (admin_general uniquement)
const getDashboardStats = async (req, res) => {
  try {
    const communesCount = await Commune.count();
    const administrateursCount = await Administrateur.count();
    const agentsCount = await Agent.count();

    res.status(200).json({
      communes: communesCount,
      administrateurs: administrateursCount,
      agents: agentsCount
    });
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors du chargement des statistiques', error });
  }
};

// ✅ Export des fonctions
module.exports = {
  getAllStatuts,
  createStatut,
  getDashboardStats
};