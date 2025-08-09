const { Demande, Citoyen, Statut } = require('../models');

exports.getAllDemandes = async (req, res) => {
  try {
    const demandes = await Demande.findAll({
      include: [{ model: Citoyen }, { model: Statut }]
    });
    res.json(demandes);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error });
  }
};

exports.getDemandeById = async (req, res) => {
  try {
    const demande = await Demande.findByPk(req.params.id, {
      include: [{ model: Citoyen }, { model: Statut }]
    });
    if (!demande) return res.status(404).json({ message: 'Demande non trouvée' });
    res.json(demande);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error });
  }
};

exports.createDemande = async (req, res) => {
  try {
    const nouvelleDemande = await Demande.create(req.body);
    res.status(201).json(nouvelleDemande);
  } catch (error) {
    res.status(400).json({ message: 'Erreur création demande', error });
  }
};

exports.updateDemande = async (req, res) => {
  try {
    const demande = await Demande.findByPk(req.params.id);
    if (!demande) return res.status(404).json({ message: 'Demande non trouvée' });

    await demande.update(req.body);
    res.json(demande);
  } catch (error) {
    res.status(400).json({ message: 'Erreur mise à jour', error });
  }
};

exports.deleteDemande = async (req, res) => {
  try {
    const demande = await Demande.findByPk(req.params.id);
    if (!demande) return res.status(404).json({ message: 'Demande non trouvée' });

    await demande.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(400).json({ message: 'Erreur suppression', error });
  }
};