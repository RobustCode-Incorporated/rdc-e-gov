const { Citoyen, Commune, Province } = require('../models');

// Génère un code aléatoire (lettres + chiffres)
function generateRandomCode(length = 4) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// Récupérer tous les citoyens
exports.getAllCitoyens = async (req, res) => {
  try {
    const citoyens = await Citoyen.findAll();
    res.json(citoyens);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error });
  }
};

// Récupérer un citoyen par ID
exports.getCitoyenById = async (req, res) => {
  try {
    const citoyen = await Citoyen.findByPk(req.params.id);
    if (!citoyen) return res.status(404).json({ message: 'Citoyen non trouvé' });
    res.json(citoyen);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur', error });
  }
};

// Créer un nouveau citoyen avec numéro unique
exports.createCitoyen = async (req, res) => {
  try {
    const { communeId, dateNaissance } = req.body;

    // Récupérer la commune avec sa province
    const commune = await Commune.findByPk(communeId, {
      include: [{ model: Province, as: 'province' }]
    });
    if (!commune) {
      return res.status(400).json({ message: "Commune invalide" });
    }

    const provinceInitial = commune.province.nom.charAt(0).toUpperCase();
    const communeInitials = commune.nom
      .split(' ')
      .map(w => w.charAt(0).toUpperCase())
      .join('')
      .slice(0, 2); // 2 lettres max

    const birthDate = new Date(dateNaissance);
    const birthFormatted = birthDate.toISOString().split('T')[0].replace(/-/g, '');

    const randomCode = generateRandomCode();

    const numeroUnique = `${provinceInitial}-${communeInitials}-${birthFormatted}-${randomCode}`;

    const newCitoyen = await Citoyen.create({
      ...req.body,
      numeroUnique
    });

    res.status(201).json(newCitoyen);
  } catch (error) {
    console.error(error);
    res.status(400).json({ message: 'Erreur création citoyen', error });
  }
};

// Mettre à jour un citoyen
exports.updateCitoyen = async (req, res) => {
  try {
    const citoyen = await Citoyen.findByPk(req.params.id);
    if (!citoyen) return res.status(404).json({ message: 'Citoyen non trouvé' });

    await citoyen.update(req.body);
    res.json(citoyen);
  } catch (error) {
    res.status(400).json({ message: 'Erreur mise à jour', error });
  }
};

// Supprimer un citoyen
exports.deleteCitoyen = async (req, res) => {
  try {
    const citoyen = await Citoyen.findByPk(req.params.id);
    if (!citoyen) return res.status(404).json({ message: 'Citoyen non trouvé' });

    await citoyen.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(400).json({ message: 'Erreur suppression', error });
  }
};