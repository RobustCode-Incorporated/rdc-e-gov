const { Commune, Administrateur, Agent, AdministrateurGeneral } = require('../models');

exports.statsForAdminGeneral = async (req, res) => {
  try {
    const adminGeneralId = req.user.id;

    // Vérifie que l’administrateur général existe
    const adminGeneral = await AdministrateurGeneral.findByPk(adminGeneralId);
    if (!adminGeneral) {
      return res.status(404).json({ message: 'Administrateur général introuvable.' });
    }

    const provinceId = adminGeneral.provinceId;

    // 1. Communes dans sa province
    const communes = await Commune.findAll({ where: { provinceId } });
    const communeIds = communes.map(c => c.id);
    const communesCount = communeIds.length;

    // 2. Administrateurs des communes de cette province
    const administrateursCount = await Administrateur.count({
      where: { communeId: communeIds }
    });

    // 3. Agents affectés aux communes de cette province
    const agentsCount = await Agent.count({
      where: { communeId: communeIds }
    });

    res.status(200).json({
      communes: communesCount,
      administrateurs: administrateursCount,
      agents: agentsCount
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur lors du chargement des statistiques", error });
  }
};