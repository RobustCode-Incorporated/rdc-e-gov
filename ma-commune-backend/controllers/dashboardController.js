const { Op } = require('sequelize');
const { AdministrateurGeneral, Commune, Agent } = require('../models');

exports.statsForAdminGeneral = async (req, res) => {
  try {
    const adminGeneralId = req.user.id;

    const adminGeneral = await AdministrateurGeneral.findByPk(adminGeneralId);
    if (!adminGeneral) {
      return res.status(404).json({ message: 'Administrateur général introuvable.' });
    }

    const provinceId = adminGeneral.provinceId;

    // Total communes dans la province
    const totalCommunes = await Commune.count({ where: { provinceId } });

    // Communes avec bourgmestre (adminId non null)
    const communesAvecBourgmestre = await Commune.count({
      where: {
        provinceId,
        adminId: { [Op.ne]: null }
      }
    });

    const communesSansBourgmestre = totalCommunes - communesAvecBourgmestre;

    // Total agents dans la province via jointure commune
    const totalAgents = await Agent.count({
      include: [{
        model: Commune,
        as: 'commune',
        where: { provinceId }
      }]
    });

    res.status(200).json({
      totalCommunes,
      communesAvecBourgmestre,
      communesSansBourgmestre,
      totalAgents
    });

  } catch (error) {
    console.error('Erreur dashboard admin général:', error);
    res.status(500).json({
      message: "Erreur lors du chargement des statistiques",
      error: error.message
    });
  }
};